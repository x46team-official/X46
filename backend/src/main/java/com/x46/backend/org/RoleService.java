package com.x46.backend.org;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.NotFoundException;
import com.x46.backend.common.ScopeGuard;
import com.x46.backend.common.ValidationException;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class RoleService {

    private final RoleRepository roleRepository;
    private final ScopeGuard scopeGuard;

    RoleService(RoleRepository roleRepository, ScopeGuard scopeGuard) {
        this.roleRepository = roleRepository;
        this.scopeGuard = scopeGuard;
    }

    public RoleResponse create(UUID organizationId, UUID branchId, CreateRoleRequest request) {
        if (isBlank(request.roleCode())) {
            throw new ValidationException("roleCode is required");
        }
        if (isBlank(request.roleName())) {
            throw new ValidationException("roleName is required");
        }
        scopeGuard.requireOrgBranch(organizationId, branchId);
        if (roleRepository.existsByOrganizationIdAndBranchIdAndRoleCode(organizationId, branchId, request.roleCode())) {
            throw new ConflictException("Duplicate role code");
        }

        Role role = new Role();
        role.setOrganizationId(organizationId);
        role.setBranchId(branchId);
        role.setRoleCode(request.roleCode());
        role.setRoleName(request.roleName());
        role.setActive(true);
        role.setCreatedAt(OffsetDateTime.now());

        Role saved = roleRepository.save(role);
        return new RoleResponse(
                saved.getId(), saved.getOrganizationId(), saved.getBranchId(), saved.getRoleCode(), saved.getRoleName());
    }

    public List<RoleSummaryResponse> list(UUID organizationId, UUID branchId, String search) {
        scopeGuard.requireOrgBranch(organizationId, branchId);
        List<Role> roles = isBlank(search)
                ? roleRepository.findByOrganizationIdAndBranchId(organizationId, branchId)
                : roleRepository.search(organizationId, branchId, search);
        return roles.stream()
                .map(role -> new RoleSummaryResponse(role.getId(), role.getRoleCode(), role.getRoleName()))
                .toList();
    }

    public RoleDetailResponse view(UUID organizationId, UUID branchId, UUID roleId) {
        Role role = findScoped(organizationId, branchId, roleId);
        return new RoleDetailResponse(role.getId(), role.getRoleCode(), role.getRoleName(), role.getCreatedAt());
    }

    public RoleSummaryResponse update(UUID organizationId, UUID branchId, UUID roleId, UpdateRoleRequest request) {
        if (isBlank(request.roleCode()) || isBlank(request.roleName())) {
            throw new ValidationException("Validation error");
        }
        Role role = findScoped(organizationId, branchId, roleId);
        if (roleRepository.existsByOrganizationIdAndBranchIdAndRoleCodeAndIdNot(
                organizationId, branchId, request.roleCode(), roleId)) {
            throw new ConflictException("Duplicate role code");
        }

        role.setRoleCode(request.roleCode());
        role.setRoleName(request.roleName());
        Role saved = roleRepository.save(role);
        return new RoleSummaryResponse(saved.getId(), saved.getRoleCode(), saved.getRoleName());
    }

    public RoleStatusResponse updateStatus(UUID organizationId, UUID branchId, UUID roleId, RoleStatusRequest request) {
        if (request.isActive() == null) {
            throw new ValidationException("Invalid status value");
        }
        Role role = findScoped(organizationId, branchId, roleId);
        role.setActive(request.isActive());
        Role saved = roleRepository.save(role);
        return new RoleStatusResponse(saved.getId(), saved.isActive());
    }

    private Role findScoped(UUID organizationId, UUID branchId, UUID roleId) {
        return roleRepository
                .findByIdAndOrganizationIdAndBranchId(roleId, organizationId, branchId)
                .orElseThrow(() -> new NotFoundException("Role not found"));
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
