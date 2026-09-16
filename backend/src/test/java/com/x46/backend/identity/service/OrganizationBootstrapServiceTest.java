package com.x46.backend.identity.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.NotFoundException;
import com.x46.backend.common.ScopeGuard;
import com.x46.backend.common.ValidationException;
import com.x46.backend.identity.dto.BootstrapAdminRequest;
import com.x46.backend.identity.dto.BootstrapAdminResponse;
import com.x46.backend.identity.dto.RoleResponse;
import com.x46.backend.identity.dto.UserResponse;
import com.x46.backend.identity.dto.UserRoleResponse;
import com.x46.backend.security.RolePermission;
import com.x46.backend.security.RolePermissionRepository;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class OrganizationBootstrapServiceTest {

    @Mock
    private ScopeGuard scopeGuard;

    @Mock
    private RoleService roleService;

    @Mock
    private UserService userService;

    @Mock
    private UserRoleService userRoleService;

    @Mock
    private RolePermissionRepository rolePermissionRepository;

    private OrganizationBootstrapService organizationBootstrapService;

    private final UUID organizationId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();
    private final UUID roleId = UUID.randomUUID();
    private final UUID userId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        organizationBootstrapService =
                new OrganizationBootstrapService(scopeGuard, roleService, userService, userRoleService, rolePermissionRepository);
    }

    private BootstrapAdminRequest validRequest() {
        return new BootstrapAdminRequest("admin1", "admin1@x46.com", "Secret@123", "Admin", "User");
    }

    @Test
    void missingUsernameIsRejected() {
        var request = new BootstrapAdminRequest(null, null, "Secret@123", "Admin", "User");

        assertThatThrownBy(() -> organizationBootstrapService.bootstrap(organizationId, branchId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("username is required");
        verifyNoInteractions(scopeGuard, roleService, userService, userRoleService, rolePermissionRepository);
    }

    @Test
    void missingPasswordIsRejected() {
        var request = new BootstrapAdminRequest("admin1", null, null, "Admin", "User");

        assertThatThrownBy(() -> organizationBootstrapService.bootstrap(organizationId, branchId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("password is required");
    }

    @Test
    void missingFirstNameIsRejected() {
        var request = new BootstrapAdminRequest("admin1", null, "Secret@123", null, null);

        assertThatThrownBy(() -> organizationBootstrapService.bootstrap(organizationId, branchId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("firstName is required");
    }

    @Test
    void unknownOrgOrBranchIsRejected() {
        doThrow(new NotFoundException("Organization or branch not found"))
                .when(scopeGuard).requireOrgBranch(organizationId, branchId);

        assertThatThrownBy(() -> organizationBootstrapService.bootstrap(organizationId, branchId, validRequest()))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization or branch not found");
        verify(roleService, never()).create(any(), any(), any());
    }

    @Test
    void duplicateAdminRoleConflictPropagates() {
        when(roleService.create(any(), any(), any())).thenThrow(new ConflictException("Duplicate role code"));

        assertThatThrownBy(() -> organizationBootstrapService.bootstrap(organizationId, branchId, validRequest()))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate role code");
        verify(userService, never()).create(any(), any(), any());
    }

    @Test
    void duplicateUsernameConflictPropagates() {
        when(roleService.create(any(), any(), any()))
                .thenReturn(new RoleResponse(roleId, organizationId, branchId, "ADMIN", "Administrator"));
        when(userService.create(any(), any(), any())).thenThrow(new ConflictException("Duplicate username"));

        assertThatThrownBy(() -> organizationBootstrapService.bootstrap(organizationId, branchId, validRequest()))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate username");
        verify(userRoleService, never()).assign(any(), any(), any(), any());
    }

    @Test
    void bootstrapSucceedsAndGrantsEveryModule() {
        when(roleService.create(organizationId, branchId, new com.x46.backend.identity.dto.CreateRoleRequest("ADMIN", "Administrator")))
                .thenReturn(new RoleResponse(roleId, organizationId, branchId, "ADMIN", "Administrator"));
        when(userService.create(any(), any(), any())).thenReturn(new UserResponse(
                userId, organizationId, branchId, "admin1", "admin1@x46.com", "Admin", "User", true));
        when(userRoleService.assign(any(), any(), any(), any()))
                .thenReturn(new UserRoleResponse(organizationId, branchId, userId, roleId, OffsetDateTime.now()));

        BootstrapAdminResponse response =
                organizationBootstrapService.bootstrap(organizationId, branchId, validRequest());

        assertThat(response.organizationId()).isEqualTo(organizationId);
        assertThat(response.branchId()).isEqualTo(branchId);
        assertThat(response.roleId()).isEqualTo(roleId);
        assertThat(response.roleCode()).isEqualTo("ADMIN");
        assertThat(response.userId()).isEqualTo(userId);
        assertThat(response.username()).isEqualTo("admin1");

        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<RolePermission>> captor = ArgumentCaptor.forClass(List.class);
        verify(rolePermissionRepository).saveAll(captor.capture());
        List<RolePermission> granted = captor.getValue();
        assertThat(granted).hasSize(25);
        assertThat(granted).allSatisfy(permission -> {
            assertThat(permission.getOrganizationId()).isEqualTo(organizationId);
            assertThat(permission.getBranchId()).isEqualTo(branchId);
            assertThat(permission.getRoleId()).isEqualTo(roleId);
            assertThat(permission.allows(com.x46.backend.security.PermissionAction.CREATE)).isTrue();
            assertThat(permission.allows(com.x46.backend.security.PermissionAction.VIEW)).isTrue();
            assertThat(permission.allows(com.x46.backend.security.PermissionAction.UPDATE)).isTrue();
            assertThat(permission.allows(com.x46.backend.security.PermissionAction.DELETE)).isTrue();
            assertThat(permission.allows(com.x46.backend.security.PermissionAction.AUTHORIZE)).isTrue();
            assertThat(permission.allows(com.x46.backend.security.PermissionAction.PRINT)).isTrue();
            assertThat(permission.allows(com.x46.backend.security.PermissionAction.EXPORT)).isTrue();
        });
        assertThat(granted.stream().map(RolePermission::getModuleName).distinct()).hasSize(25);
    }
}
