package com.x46.backend.identity.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.when;

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
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class UserRoleServiceTest {

    @Mock
    private UserRoleRepository userRoleRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private RoleRepository roleRepository;

    @Mock
    private ScopeGuard scopeGuard;

    private UserRoleService userRoleService;

    private final UUID organizationId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();
    private final UUID userId = UUID.randomUUID();
    private final UUID roleId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        userRoleService = new UserRoleService(userRoleRepository, userRepository, roleRepository, scopeGuard);
    }

    private User existingUser() {
        User user = new User();
        user.setId(userId);
        user.setOrganizationId(organizationId);
        user.setBranchId(branchId);
        return user;
    }

    private Role existingRole() {
        Role role = new Role();
        role.setId(roleId);
        role.setOrganizationId(organizationId);
        role.setBranchId(branchId);
        return role;
    }

    @Test
    void unknownOrgOrBranchIsRejected() {
        doThrow(new NotFoundException("Organization or branch not found"))
                .when(scopeGuard).requireOrgBranch(organizationId, branchId);
        var request = new AssignRoleRequest(roleId);

        assertThatThrownBy(() -> userRoleService.assign(organizationId, branchId, userId, request))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization or branch not found");
    }

    @Test
    void unknownUserIsRejected() {
        when(userRepository.findByIdAndOrganizationIdAndBranchId(userId, organizationId, branchId))
                .thenReturn(Optional.empty());
        var request = new AssignRoleRequest(roleId);

        assertThatThrownBy(() -> userRoleService.assign(organizationId, branchId, userId, request))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("User not found");
    }

    @Test
    void unknownRoleIsRejected() {
        when(userRepository.findByIdAndOrganizationIdAndBranchId(userId, organizationId, branchId))
                .thenReturn(Optional.of(existingUser()));
        when(roleRepository.findByIdAndOrganizationIdAndBranchId(roleId, organizationId, branchId))
                .thenReturn(Optional.empty());
        var request = new AssignRoleRequest(roleId);

        assertThatThrownBy(() -> userRoleService.assign(organizationId, branchId, userId, request))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Role not found");
    }

    @Test
    void duplicateAssignmentIsRejected() {
        when(userRepository.findByIdAndOrganizationIdAndBranchId(userId, organizationId, branchId))
                .thenReturn(Optional.of(existingUser()));
        when(roleRepository.findByIdAndOrganizationIdAndBranchId(roleId, organizationId, branchId))
                .thenReturn(Optional.of(existingRole()));
        when(userRoleRepository.existsByUserIdAndRoleId(userId, roleId)).thenReturn(true);
        var request = new AssignRoleRequest(roleId);

        assertThatThrownBy(() -> userRoleService.assign(organizationId, branchId, userId, request))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Role already assigned to user");
    }

    @Test
    void assignSucceeds() {
        when(userRepository.findByIdAndOrganizationIdAndBranchId(userId, organizationId, branchId))
                .thenReturn(Optional.of(existingUser()));
        when(roleRepository.findByIdAndOrganizationIdAndBranchId(roleId, organizationId, branchId))
                .thenReturn(Optional.of(existingRole()));
        when(userRoleRepository.existsByUserIdAndRoleId(userId, roleId)).thenReturn(false);
        when(userRoleRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        var request = new AssignRoleRequest(roleId);

        UserRoleResponse response = userRoleService.assign(organizationId, branchId, userId, request);

        assertThat(response.organizationId()).isEqualTo(organizationId);
        assertThat(response.branchId()).isEqualTo(branchId);
        assertThat(response.userId()).isEqualTo(userId);
        assertThat(response.roleId()).isEqualTo(roleId);
        assertThat(response.assignedAt()).isNotNull();
    }
}
