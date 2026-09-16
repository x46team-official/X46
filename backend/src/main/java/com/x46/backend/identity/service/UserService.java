package com.x46.backend.identity.service;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.NotFoundException;
import com.x46.backend.common.ScopeGuard;
import com.x46.backend.common.ValidationException;
import com.x46.backend.identity.dto.CreateUserRequest;
import com.x46.backend.identity.dto.OrganizationUserResponse;
import com.x46.backend.identity.dto.UpdateUserRequest;
import com.x46.backend.identity.dto.UserDetailResponse;
import com.x46.backend.identity.dto.UserResponse;
import com.x46.backend.identity.dto.UserStatusRequest;
import com.x46.backend.identity.dto.UserStatusResponse;
import com.x46.backend.identity.dto.UserSummaryResponse;
import com.x46.backend.identity.dto.UserUpdateResponse;
import com.x46.backend.identity.entity.User;
import com.x46.backend.identity.repository.UserRepository;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final ScopeGuard scopeGuard;
    private final PasswordEncoder passwordEncoder;
    private final JdbcTemplate jdbcTemplate;

    UserService(
            UserRepository userRepository,
            ScopeGuard scopeGuard,
            PasswordEncoder passwordEncoder,
            JdbcTemplate jdbcTemplate) {
        this.userRepository = userRepository;
        this.scopeGuard = scopeGuard;
        this.passwordEncoder = passwordEncoder;
        this.jdbcTemplate = jdbcTemplate;
    }

    public UserResponse create(UUID organizationId, UUID branchId, CreateUserRequest request) {
        if (isBlank(request.username())) {
            throw new ValidationException("username is required");
        }
        if (isBlank(request.password())) {
            throw new ValidationException("password is required");
        }
        if (isBlank(request.firstName())) {
            throw new ValidationException("firstName is required");
        }
        scopeGuard.requireOrgBranch(organizationId, branchId);

        // plan.md gap #8: usernames are globally unique (V44), auto-prefixed
        // with their org's code (e.g. "ACME-jdoe") so a single-field login
        // (username + password only, no org/branch code) can resolve them.
        String organizationCode =
                jdbcTemplate.queryForObject("SELECT organization_code FROM organizations WHERE id = ?", String.class, organizationId);
        String prefixedUsername = organizationCode + "-" + request.username();
        if (userRepository.existsByUsername(prefixedUsername)) {
            throw new ConflictException("Duplicate username");
        }

        User user = new User();
        user.setOrganizationId(organizationId);
        user.setBranchId(branchId);
        user.setUsername(prefixedUsername);
        user.setEmail(request.email());
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setFirstName(request.firstName());
        user.setLastName(request.lastName());
        user.setActive(request.isActive() == null || request.isActive());
        OffsetDateTime now = OffsetDateTime.now();
        user.setCreatedAt(now);
        user.setUpdatedAt(now);

        User saved = userRepository.save(user);
        return new UserResponse(
                saved.getId(),
                saved.getOrganizationId(),
                saved.getBranchId(),
                saved.getUsername(),
                saved.getEmail(),
                saved.getFirstName(),
                saved.getLastName(),
                saved.isActive());
    }

    public List<UserSummaryResponse> list(UUID organizationId, UUID branchId, Boolean isActive, String search) {
        scopeGuard.requireOrgBranch(organizationId, branchId);
        List<User> users;
        if (isBlank(search) && isActive == null) {
            users = userRepository.findByOrganizationIdAndBranchId(organizationId, branchId);
        } else if (isBlank(search)) {
            users = userRepository.findByOrganizationIdAndBranchIdAndActive(organizationId, branchId, isActive);
        } else if (isActive == null) {
            users = userRepository.search(organizationId, branchId, search);
        } else {
            users = userRepository.searchByActive(organizationId, branchId, isActive, search);
        }
        return users.stream()
                .map(user -> new UserSummaryResponse(
                        user.getId(), user.getUsername(), user.getEmail(), user.getFirstName(), user.getLastName(),
                        user.isActive()))
                .toList();
    }

    /** Cross-branch listing for the platform-admin dashboard (plan.md gap #7, Chunk 1.8). */
    public List<OrganizationUserResponse> listByOrganization(UUID organizationId) {
        scopeGuard.requireOrg(organizationId);
        return jdbcTemplate.query(
                "SELECT u.id, u.branch_id, b.branch_code, u.username, u.email, u.first_name, u.last_name, u.is_active "
                        + "FROM users u JOIN branches b ON b.id = u.branch_id "
                        + "WHERE u.organization_id = ? ORDER BY b.branch_code, u.username",
                (rs, rowNum) -> new OrganizationUserResponse(
                        (UUID) rs.getObject("id"),
                        (UUID) rs.getObject("branch_id"),
                        rs.getString("branch_code"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("first_name"),
                        rs.getString("last_name"),
                        rs.getBoolean("is_active")),
                organizationId);
    }

    public UserDetailResponse view(UUID organizationId, UUID branchId, UUID userId) {
        User user = findScoped(organizationId, branchId, userId);
        List<UserDetailResponse.RoleAssignment> roles = jdbcTemplate.query(
                "SELECT ur.role_id, r.role_code, r.role_name, ur.assigned_at FROM user_roles ur "
                        + "JOIN roles r ON r.id = ur.role_id WHERE ur.user_id = ?",
                (rs, rowNum) -> new UserDetailResponse.RoleAssignment(
                        (UUID) rs.getObject("role_id"),
                        rs.getString("role_code"),
                        rs.getString("role_name"),
                        rs.getObject("assigned_at", OffsetDateTime.class)),
                userId);
        return new UserDetailResponse(
                user.getId(), user.getUsername(), user.getEmail(), user.getFirstName(), user.getLastName(),
                user.isActive(), roles);
    }

    public UserUpdateResponse update(UUID organizationId, UUID branchId, UUID userId, UpdateUserRequest request) {
        if (isBlank(request.firstName())) {
            throw new ValidationException("firstName is required");
        }
        User user = findScoped(organizationId, branchId, userId);
        user.setEmail(request.email());
        user.setFirstName(request.firstName());
        user.setLastName(request.lastName());
        user.setUpdatedAt(OffsetDateTime.now());
        User saved = userRepository.save(user);
        return new UserUpdateResponse(saved.getId(), saved.getFirstName(), saved.getLastName(), saved.getEmail());
    }

    public UserStatusResponse updateStatus(UUID organizationId, UUID branchId, UUID userId, UserStatusRequest request) {
        if (request.isActive() == null) {
            throw new ValidationException("Invalid status value");
        }
        User user = findScoped(organizationId, branchId, userId);
        user.setActive(request.isActive());
        user.setUpdatedAt(OffsetDateTime.now());
        User saved = userRepository.save(user);
        return new UserStatusResponse(saved.getId(), saved.isActive());
    }

    private User findScoped(UUID organizationId, UUID branchId, UUID userId) {
        return userRepository
                .findByIdAndOrganizationIdAndBranchId(userId, organizationId, branchId)
                .orElseThrow(() -> new NotFoundException("User not found"));
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
