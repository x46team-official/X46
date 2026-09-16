package com.x46.backend.identity.service;

import com.x46.backend.common.ScopeGuard;
import com.x46.backend.common.ValidationException;
import com.x46.backend.identity.dto.AssignRoleRequest;
import com.x46.backend.identity.dto.BootstrapAdminRequest;
import com.x46.backend.identity.dto.BootstrapAdminResponse;
import com.x46.backend.identity.dto.CreateRoleRequest;
import com.x46.backend.identity.dto.CreateUserRequest;
import com.x46.backend.identity.dto.RoleResponse;
import com.x46.backend.identity.dto.UserResponse;
import com.x46.backend.security.RolePermission;
import com.x46.backend.security.RolePermissionRepository;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Bootstraps the first working login for a brand-new organization: an ADMIN
 * role with every module_name granted, a user, and the assignment between
 * them. Composes RoleService/UserService/UserRoleService rather than
 * duplicating their validation/creation logic (plan.md gap #7) - the only
 * genuinely new piece is seeding role_permission across every Appendix A
 * module, which no existing service does.
 */
@Service
public class OrganizationBootstrapService {

    private static final List<String> ALL_MODULES = List.of(
            "Organization Management",
            "Branch Management",
            "Role Management",
            "User Management",
            "User Role Management",
            "Test Management",
            "Department Management",
            "Reference Range Master",
            "Test Package Management",
            "Patient Management",
            "Patient Registration",
            "Clinical History",
            "Billing",
            "Accession",
            "Payment",
            "Sample Collection",
            "Worklist Management",
            "Result Entry",
            "Result Authorization",
            "Report Generation",
            "Report Delivery",
            "Outsource",
            "Finance Overview",
            "Finance Reports",
            "Most Tested Tests");

    private final ScopeGuard scopeGuard;
    private final RoleService roleService;
    private final UserService userService;
    private final UserRoleService userRoleService;
    private final RolePermissionRepository rolePermissionRepository;

    OrganizationBootstrapService(
            ScopeGuard scopeGuard,
            RoleService roleService,
            UserService userService,
            UserRoleService userRoleService,
            RolePermissionRepository rolePermissionRepository) {
        this.scopeGuard = scopeGuard;
        this.roleService = roleService;
        this.userService = userService;
        this.userRoleService = userRoleService;
        this.rolePermissionRepository = rolePermissionRepository;
    }

    @Transactional
    public BootstrapAdminResponse bootstrap(UUID organizationId, UUID branchId, BootstrapAdminRequest request) {
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

        RoleResponse role = roleService.create(organizationId, branchId, new CreateRoleRequest("ADMIN", "Administrator"));
        grantAllModules(organizationId, branchId, role.id());

        UserResponse user = userService.create(
                organizationId,
                branchId,
                new CreateUserRequest(
                        request.username(), request.email(), request.password(), request.firstName(),
                        request.lastName(), true));

        userRoleService.assign(organizationId, branchId, user.id(), new AssignRoleRequest(role.id()));

        return new BootstrapAdminResponse(organizationId, branchId, role.id(), role.roleCode(), user.id(), user.username());
    }

    private void grantAllModules(UUID organizationId, UUID branchId, UUID roleId) {
        OffsetDateTime now = OffsetDateTime.now();
        List<RolePermission> permissions = ALL_MODULES.stream()
                .map(moduleName -> {
                    RolePermission permission = new RolePermission();
                    permission.setOrganizationId(organizationId);
                    permission.setBranchId(branchId);
                    permission.setRoleId(roleId);
                    permission.setModuleName(moduleName);
                    permission.setCanCreate(true);
                    permission.setCanView(true);
                    permission.setCanUpdate(true);
                    permission.setCanDelete(true);
                    permission.setCanAuthorize(true);
                    permission.setCanPrint(true);
                    permission.setCanExport(true);
                    permission.setCreatedAt(now);
                    permission.setUpdatedAt(now);
                    return permission;
                })
                .toList();
        rolePermissionRepository.saveAll(permissions);
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
