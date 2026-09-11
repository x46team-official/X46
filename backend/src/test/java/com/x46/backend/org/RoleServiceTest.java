package com.x46.backend.org;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.NotFoundException;
import com.x46.backend.common.ScopeGuard;
import com.x46.backend.common.ValidationException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class RoleServiceTest {

    @Mock
    private RoleRepository roleRepository;

    @Mock
    private ScopeGuard scopeGuard;

    private RoleService roleService;

    private final UUID organizationId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();
    private final UUID roleId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        roleService = new RoleService(roleRepository, scopeGuard);
    }

    private Role existingRole() {
        Role role = new Role();
        role.setId(roleId);
        role.setOrganizationId(organizationId);
        role.setBranchId(branchId);
        role.setRoleCode("ADMIN");
        role.setRoleName("Administrator");
        role.setActive(true);
        return role;
    }

    // --- create (API-003) ---

    @Test
    void createMissingRoleCodeIsRejected() {
        var request = new CreateRoleRequest(null, "Administrator");

        assertThatThrownBy(() -> roleService.create(organizationId, branchId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("roleCode is required");
        verifyNoInteractions(scopeGuard, roleRepository);
    }

    @Test
    void createMissingRoleNameIsRejected() {
        var request = new CreateRoleRequest("ADMIN", null);

        assertThatThrownBy(() -> roleService.create(organizationId, branchId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("roleName is required");
        verifyNoInteractions(scopeGuard, roleRepository);
    }

    @Test
    void createUnknownOrgOrBranchIsRejected() {
        doThrow(new NotFoundException("Organization or branch not found"))
                .when(scopeGuard).requireOrgBranch(organizationId, branchId);
        var request = new CreateRoleRequest("ADMIN", "Administrator");

        assertThatThrownBy(() -> roleService.create(organizationId, branchId, request))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization or branch not found");
    }

    @Test
    void createDuplicateRoleCodeIsRejected() {
        when(roleRepository.existsByOrganizationIdAndBranchIdAndRoleCode(organizationId, branchId, "ADMIN"))
                .thenReturn(true);
        var request = new CreateRoleRequest("ADMIN", "Administrator");

        assertThatThrownBy(() -> roleService.create(organizationId, branchId, request))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate role code");
    }

    @Test
    void createSucceeds() {
        when(roleRepository.existsByOrganizationIdAndBranchIdAndRoleCode(organizationId, branchId, "ADMIN"))
                .thenReturn(false);
        when(roleRepository.save(any())).thenAnswer(invocation -> {
            Role role = invocation.getArgument(0);
            role.setId(roleId);
            return role;
        });
        var request = new CreateRoleRequest("ADMIN", "Administrator");

        RoleResponse response = roleService.create(organizationId, branchId, request);

        assertThat(response.id()).isEqualTo(roleId);
        assertThat(response.organizationId()).isEqualTo(organizationId);
        assertThat(response.branchId()).isEqualTo(branchId);
        assertThat(response.roleCode()).isEqualTo("ADMIN");
        assertThat(response.roleName()).isEqualTo("Administrator");
    }

    // --- list (API-129 op1) ---

    @Test
    void listUnknownOrgOrBranchIsRejected() {
        doThrow(new NotFoundException("Organization or branch not found"))
                .when(scopeGuard).requireOrgBranch(organizationId, branchId);

        assertThatThrownBy(() -> roleService.list(organizationId, branchId, null))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization or branch not found");
    }

    @Test
    void listSucceeds() {
        when(roleRepository.findByOrganizationIdAndBranchId(organizationId, branchId))
                .thenReturn(List.of(existingRole()));

        List<RoleSummaryResponse> response = roleService.list(organizationId, branchId, "");

        assertThat(response).hasSize(1);
        assertThat(response.get(0).roleCode()).isEqualTo("ADMIN");
    }

    @Test
    void listWithSearchFiltersByCodeOrName() {
        when(roleRepository.search(organizationId, branchId, "adm")).thenReturn(List.of(existingRole()));

        List<RoleSummaryResponse> response = roleService.list(organizationId, branchId, "adm");

        assertThat(response).hasSize(1);
        assertThat(response.get(0).roleCode()).isEqualTo("ADMIN");
    }

    // --- view (API-129 op2) ---

    @Test
    void viewUnknownRoleIsRejected() {
        when(roleRepository.findByIdAndOrganizationIdAndBranchId(roleId, organizationId, branchId))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> roleService.view(organizationId, branchId, roleId))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Role not found");
    }

    @Test
    void viewSucceeds() {
        when(roleRepository.findByIdAndOrganizationIdAndBranchId(roleId, organizationId, branchId))
                .thenReturn(Optional.of(existingRole()));

        RoleDetailResponse response = roleService.view(organizationId, branchId, roleId);

        assertThat(response.id()).isEqualTo(roleId);
        assertThat(response.roleCode()).isEqualTo("ADMIN");
        assertThat(response.roleName()).isEqualTo("Administrator");
    }

    // --- update (API-129 op3) ---

    @Test
    void updateMissingFieldsIsRejected() {
        var request = new UpdateRoleRequest("", "Administrator");

        assertThatThrownBy(() -> roleService.update(organizationId, branchId, roleId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Validation error");
        verifyNoInteractions(roleRepository);
    }

    @Test
    void updateUnknownRoleIsRejected() {
        when(roleRepository.findByIdAndOrganizationIdAndBranchId(roleId, organizationId, branchId))
                .thenReturn(Optional.empty());
        var request = new UpdateRoleRequest("ADMIN2", "Administrator Updated");

        assertThatThrownBy(() -> roleService.update(organizationId, branchId, roleId, request))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Role not found");
    }

    @Test
    void updateDuplicateRoleCodeIsRejected() {
        when(roleRepository.findByIdAndOrganizationIdAndBranchId(roleId, organizationId, branchId))
                .thenReturn(Optional.of(existingRole()));
        when(roleRepository.existsByOrganizationIdAndBranchIdAndRoleCodeAndIdNot(
                        organizationId, branchId, "OPS", roleId))
                .thenReturn(true);
        var request = new UpdateRoleRequest("OPS", "Operations");

        assertThatThrownBy(() -> roleService.update(organizationId, branchId, roleId, request))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate role code");
    }

    @Test
    void updateSucceeds() {
        when(roleRepository.findByIdAndOrganizationIdAndBranchId(roleId, organizationId, branchId))
                .thenReturn(Optional.of(existingRole()));
        when(roleRepository.existsByOrganizationIdAndBranchIdAndRoleCodeAndIdNot(
                        eq(organizationId), eq(branchId), anyString(), eq(roleId)))
                .thenReturn(false);
        when(roleRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        var request = new UpdateRoleRequest("ADMIN", "Administrator Updated");

        RoleSummaryResponse response = roleService.update(organizationId, branchId, roleId, request);

        assertThat(response.roleName()).isEqualTo("Administrator Updated");
    }

    // --- updateStatus (API-129 op4) ---

    @Test
    void statusMissingIsActiveIsRejected() {
        var request = new RoleStatusRequest(null);

        assertThatThrownBy(() -> roleService.updateStatus(organizationId, branchId, roleId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Invalid status value");
        verifyNoInteractions(roleRepository);
    }

    @Test
    void statusUnknownRoleIsRejected() {
        when(roleRepository.findByIdAndOrganizationIdAndBranchId(roleId, organizationId, branchId))
                .thenReturn(Optional.empty());
        var request = new RoleStatusRequest(false);

        assertThatThrownBy(() -> roleService.updateStatus(organizationId, branchId, roleId, request))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Role not found");
    }

    @Test
    void statusSucceeds() {
        when(roleRepository.findByIdAndOrganizationIdAndBranchId(roleId, organizationId, branchId))
                .thenReturn(Optional.of(existingRole()));
        when(roleRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        var request = new RoleStatusRequest(false);

        RoleStatusResponse response = roleService.updateStatus(organizationId, branchId, roleId, request);

        assertThat(response.id()).isEqualTo(roleId);
        assertThat(response.isActive()).isFalse();
        verify(roleRepository).save(any());
    }
}
