package com.x46.backend.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

@ExtendWith(MockitoExtension.class)
class PermissionEvaluatorServiceTest {

    private static final UUID ORG_ID = UUID.randomUUID();
    private static final UUID BRANCH_ID = UUID.randomUUID();
    private static final UUID OTHER_BRANCH_ID = UUID.randomUUID();
    private static final UUID ROLE_ID = UUID.randomUUID();

    @Mock
    private RolePermissionRepository rolePermissionRepository;

    private void loginAs(UUID branchId, UUID... roleIds) {
        JwtPrincipal principal = new JwtPrincipal(UUID.randomUUID(), ORG_ID, branchId, List.of(roleIds));
        SecurityContextHolder.getContext()
                .setAuthentication(new UsernamePasswordAuthenticationToken(principal, null, List.of()));
    }

    @AfterEach
    void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    private RolePermission permissionRow(boolean canCreate) {
        RolePermission permission = new RolePermission();
        permission.setOrganizationId(ORG_ID);
        permission.setBranchId(BRANCH_ID);
        permission.setRoleId(ROLE_ID);
        permission.setModuleName("Billing");
        permission.setCanCreate(canCreate);
        return permission;
    }

    @Test
    void allowsWhenTheMatchingFlagIsTrue() {
        loginAs(BRANCH_ID, ROLE_ID);
        when(rolePermissionRepository.findByOrganizationIdAndBranchIdAndRoleIdInAndModuleName(
                        ORG_ID, BRANCH_ID, List.of(ROLE_ID), "Billing"))
                .thenReturn(List.of(permissionRow(true)));

        PermissionEvaluatorService permissionEvaluatorService = new PermissionEvaluatorService(rolePermissionRepository);

        assertThat(permissionEvaluatorService.can("Billing", "CREATE")).isTrue();
    }

    @Test
    void deniesWhenTheFlagIsFalse() {
        loginAs(BRANCH_ID, ROLE_ID);
        when(rolePermissionRepository.findByOrganizationIdAndBranchIdAndRoleIdInAndModuleName(
                        ORG_ID, BRANCH_ID, List.of(ROLE_ID), "Billing"))
                .thenReturn(List.of(permissionRow(false)));

        PermissionEvaluatorService permissionEvaluatorService = new PermissionEvaluatorService(rolePermissionRepository);

        assertThat(permissionEvaluatorService.can("Billing", "CREATE")).isFalse();
    }

    @Test
    void deniesWhenNoRoleHasAPermissionRowForThatModule() {
        loginAs(BRANCH_ID, ROLE_ID);
        when(rolePermissionRepository.findByOrganizationIdAndBranchIdAndRoleIdInAndModuleName(
                        ORG_ID, BRANCH_ID, List.of(ROLE_ID), "Billing"))
                .thenReturn(List.of());

        PermissionEvaluatorService permissionEvaluatorService = new PermissionEvaluatorService(rolePermissionRepository);

        assertThat(permissionEvaluatorService.can("Billing", "CREATE")).isFalse();
    }

    @Test
    void deniesWhenTheGrantIsForADifferentBranch() {
        loginAs(OTHER_BRANCH_ID, ROLE_ID);
        when(rolePermissionRepository.findByOrganizationIdAndBranchIdAndRoleIdInAndModuleName(
                        ORG_ID, OTHER_BRANCH_ID, List.of(ROLE_ID), "Billing"))
                .thenReturn(List.of());

        PermissionEvaluatorService permissionEvaluatorService = new PermissionEvaluatorService(rolePermissionRepository);

        assertThat(permissionEvaluatorService.can("Billing", "CREATE")).isFalse();
    }
}
