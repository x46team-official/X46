package com.x46.backend.identity.service;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.NotFoundException;
import com.x46.backend.common.ScopeGuard;
import com.x46.backend.identity.dto.AssignRoleRequest;
import com.x46.backend.identity.dto.UserRoleResponse;
import com.x46.backend.identity.entity.Role;
import com.x46.backend.identity.entity.User;
import com.x46.backend.identity.entity.UserRole;
import com.x46.backend.identity.repository.RoleRepository;
import com.x46.backend.identity.repository.UserRepository;
import com.x46.backend.identity.repository.UserRoleRepository;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class UserRoleService {

    private final UserRoleRepository userRoleRepository;
    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final ScopeGuard scopeGuard;

    UserRoleService(
            UserRoleRepository userRoleRepository,
            UserRepository userRepository,
            RoleRepository roleRepository,
            ScopeGuard scopeGuard) {
        this.userRoleRepository = userRoleRepository;
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.scopeGuard = scopeGuard;
    }

    public UserRoleResponse assign(UUID organizationId, UUID branchId, UUID userId, AssignRoleRequest request) {
        scopeGuard.requireOrgBranch(organizationId, branchId);

        User user = userRepository
                .findByIdAndOrganizationIdAndBranchId(userId, organizationId, branchId)
                .orElseThrow(() -> new NotFoundException("User not found"));
        Role role = roleRepository
                .findByIdAndOrganizationIdAndBranchId(request.roleId(), organizationId, branchId)
                .orElseThrow(() -> new NotFoundException("Role not found"));

        if (userRoleRepository.existsByUserIdAndRoleId(user.getId(), role.getId())) {
            throw new ConflictException("Role already assigned to user");
        }

        UserRole userRole = new UserRole();
        userRole.setOrganizationId(organizationId);
        userRole.setBranchId(branchId);
        userRole.setUserId(user.getId());
        userRole.setRoleId(role.getId());
        userRole.setAssignedAt(OffsetDateTime.now());

        UserRole saved = userRoleRepository.save(userRole);
        return new UserRoleResponse(
                saved.getOrganizationId(), saved.getBranchId(), saved.getUserId(), saved.getRoleId(),
                saved.getAssignedAt());
    }
}
