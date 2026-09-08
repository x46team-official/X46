package com.x46.backend.security;

import java.util.List;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

@Service("perm")
public class PermissionEvaluatorService {

    private final RolePermissionRepository rolePermissionRepository;

    PermissionEvaluatorService(RolePermissionRepository rolePermissionRepository) {
        this.rolePermissionRepository = rolePermissionRepository;
    }

    public boolean can(String moduleName, String action) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication != null && authentication.getPrincipal() instanceof JwtPrincipal principal)) {
            return false;
        }
        if (principal.roleIds().isEmpty()) {
            return false;
        }

        PermissionAction parsedAction;
        try {
            parsedAction = PermissionAction.valueOf(action);
        } catch (IllegalArgumentException ex) {
            return false;
        }

        List<RolePermission> permissions = rolePermissionRepository
                .findByOrganizationIdAndBranchIdAndRoleIdInAndModuleName(
                        principal.organizationId(), principal.branchId(), principal.roleIds(), moduleName);

        return permissions.stream().anyMatch(permission -> permission.allows(parsedAction));
    }
}
