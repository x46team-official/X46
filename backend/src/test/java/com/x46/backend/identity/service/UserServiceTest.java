package com.x46.backend.identity.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.NotFoundException;
import com.x46.backend.common.ScopeGuard;
import com.x46.backend.common.ValidationException;
import com.x46.backend.identity.dto.CreateUserRequest;
import com.x46.backend.identity.dto.UpdateUserRequest;
import com.x46.backend.identity.dto.UserDetailResponse;
import com.x46.backend.identity.dto.UserResponse;
import com.x46.backend.identity.dto.UserStatusRequest;
import com.x46.backend.identity.dto.UserStatusResponse;
import com.x46.backend.identity.dto.UserSummaryResponse;
import com.x46.backend.identity.dto.UserUpdateResponse;
import com.x46.backend.identity.entity.User;
import com.x46.backend.identity.repository.UserRepository;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private ScopeGuard scopeGuard;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JdbcTemplate jdbcTemplate;

    private UserService userService;

    private final UUID organizationId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();
    private final UUID userId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        userService = new UserService(userRepository, scopeGuard, passwordEncoder, jdbcTemplate);
    }

    private User existingUser() {
        User user = new User();
        user.setId(userId);
        user.setOrganizationId(organizationId);
        user.setBranchId(branchId);
        user.setUsername("jdoe");
        user.setEmail("jdoe@x46.com");
        user.setPasswordHash("hashed");
        user.setFirstName("John");
        user.setLastName("Doe");
        user.setActive(true);
        return user;
    }

    // --- create (API-004) ---

    @Test
    void createMissingUsernameIsRejected() {
        var request = new CreateUserRequest(null, "e@x.com", "pass", "John", "Doe", null);

        assertThatThrownBy(() -> userService.create(organizationId, branchId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("username is required");
        verifyNoInteractions(scopeGuard, userRepository);
    }

    @Test
    void createMissingPasswordIsRejected() {
        var request = new CreateUserRequest("jdoe", "e@x.com", null, "John", "Doe", null);

        assertThatThrownBy(() -> userService.create(organizationId, branchId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("password is required");
        verifyNoInteractions(scopeGuard, userRepository);
    }

    @Test
    void createMissingFirstNameIsRejected() {
        var request = new CreateUserRequest("jdoe", "e@x.com", "pass", null, "Doe", null);

        assertThatThrownBy(() -> userService.create(organizationId, branchId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("firstName is required");
        verifyNoInteractions(scopeGuard, userRepository);
    }

    @Test
    void createUnknownOrgOrBranchIsRejected() {
        doThrow(new NotFoundException("Organization or branch not found"))
                .when(scopeGuard).requireOrgBranch(organizationId, branchId);
        var request = new CreateUserRequest("jdoe", "e@x.com", "pass", "John", "Doe", null);

        assertThatThrownBy(() -> userService.create(organizationId, branchId, request))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization or branch not found");
    }

    @Test
    void createDuplicateUsernameIsRejected() {
        when(userRepository.existsByOrganizationIdAndBranchIdAndUsername(organizationId, branchId, "jdoe"))
                .thenReturn(true);
        var request = new CreateUserRequest("jdoe", "e@x.com", "pass", "John", "Doe", null);

        assertThatThrownBy(() -> userService.create(organizationId, branchId, request))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate username");
    }

    @Test
    void createSucceedsWithDefaultActiveTrue() {
        when(userRepository.existsByOrganizationIdAndBranchIdAndUsername(organizationId, branchId, "jdoe"))
                .thenReturn(false);
        when(passwordEncoder.encode("pass")).thenReturn("hashed");
        when(userRepository.save(any())).thenAnswer(invocation -> {
            User user = invocation.getArgument(0);
            user.setId(userId);
            return user;
        });
        var request = new CreateUserRequest("jdoe", "e@x.com", "pass", "John", "Doe", null);

        UserResponse response = userService.create(organizationId, branchId, request);

        assertThat(response.id()).isEqualTo(userId);
        assertThat(response.organizationId()).isEqualTo(organizationId);
        assertThat(response.branchId()).isEqualTo(branchId);
        assertThat(response.username()).isEqualTo("jdoe");
        assertThat(response.isActive()).isTrue();
    }

    @Test
    void createSucceedsWithExplicitActiveFalse() {
        when(userRepository.existsByOrganizationIdAndBranchIdAndUsername(organizationId, branchId, "jdoe"))
                .thenReturn(false);
        when(passwordEncoder.encode("pass")).thenReturn("hashed");
        when(userRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        var request = new CreateUserRequest("jdoe", "e@x.com", "pass", "John", "Doe", false);

        UserResponse response = userService.create(organizationId, branchId, request);

        assertThat(response.isActive()).isFalse();
    }

    // --- list (API-128 op1) ---

    @Test
    void listUnknownOrgOrBranchIsRejected() {
        doThrow(new NotFoundException("Organization or branch not found"))
                .when(scopeGuard).requireOrgBranch(organizationId, branchId);

        assertThatThrownBy(() -> userService.list(organizationId, branchId, null, null))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization or branch not found");
    }

    @Test
    void listWithNoFiltersReturnsAll() {
        when(userRepository.findByOrganizationIdAndBranchId(organizationId, branchId))
                .thenReturn(List.of(existingUser()));

        List<UserSummaryResponse> response = userService.list(organizationId, branchId, null, null);

        assertThat(response).hasSize(1);
        assertThat(response.get(0).username()).isEqualTo("jdoe");
    }

    @Test
    void listWithActiveFilterOnly() {
        when(userRepository.findByOrganizationIdAndBranchIdAndActive(organizationId, branchId, true))
                .thenReturn(List.of(existingUser()));

        List<UserSummaryResponse> response = userService.list(organizationId, branchId, true, null);

        assertThat(response).hasSize(1);
    }

    @Test
    void listWithSearchOnly() {
        when(userRepository.search(organizationId, branchId, "jd")).thenReturn(List.of(existingUser()));

        List<UserSummaryResponse> response = userService.list(organizationId, branchId, null, "jd");

        assertThat(response).hasSize(1);
    }

    @Test
    void listWithSearchAndActive() {
        when(userRepository.searchByActive(organizationId, branchId, true, "jd"))
                .thenReturn(List.of(existingUser()));

        List<UserSummaryResponse> response = userService.list(organizationId, branchId, true, "jd");

        assertThat(response).hasSize(1);
    }

    // --- view (API-128 op2) ---

    @Test
    void viewUnknownUserIsRejected() {
        when(userRepository.findByIdAndOrganizationIdAndBranchId(userId, organizationId, branchId))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.view(organizationId, branchId, userId))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("User not found");
    }

    @Test
    void viewSucceeds() {
        when(userRepository.findByIdAndOrganizationIdAndBranchId(userId, organizationId, branchId))
                .thenReturn(Optional.of(existingUser()));
        when(jdbcTemplate.query(any(String.class), any(org.springframework.jdbc.core.RowMapper.class), any(UUID.class)))
                .thenReturn(List.of());

        UserDetailResponse response = userService.view(organizationId, branchId, userId);

        assertThat(response.id()).isEqualTo(userId);
        assertThat(response.username()).isEqualTo("jdoe");
        assertThat(response.roles()).isEmpty();
    }

    // --- update (API-128 op3) ---

    @Test
    void updateMissingFirstNameIsRejected() {
        var request = new UpdateUserRequest("e@x.com", null, "Doe");

        assertThatThrownBy(() -> userService.update(organizationId, branchId, userId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("firstName is required");
        verifyNoInteractions(userRepository);
    }

    @Test
    void updateUnknownUserIsRejected() {
        when(userRepository.findByIdAndOrganizationIdAndBranchId(userId, organizationId, branchId))
                .thenReturn(Optional.empty());
        var request = new UpdateUserRequest("e@x.com", "John", "Doe Updated");

        assertThatThrownBy(() -> userService.update(organizationId, branchId, userId, request))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("User not found");
    }

    @Test
    void updateSucceeds() {
        when(userRepository.findByIdAndOrganizationIdAndBranchId(userId, organizationId, branchId))
                .thenReturn(Optional.of(existingUser()));
        when(userRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        var request = new UpdateUserRequest("new@x.com", "John", "Doe Updated");

        UserUpdateResponse response = userService.update(organizationId, branchId, userId, request);

        assertThat(response.firstName()).isEqualTo("John");
        assertThat(response.lastName()).isEqualTo("Doe Updated");
        assertThat(response.email()).isEqualTo("new@x.com");
    }

    // --- updateStatus (API-128 op4) ---

    @Test
    void statusMissingIsActiveIsRejected() {
        var request = new UserStatusRequest(null);

        assertThatThrownBy(() -> userService.updateStatus(organizationId, branchId, userId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Invalid status value");
        verifyNoInteractions(userRepository);
    }

    @Test
    void statusUnknownUserIsRejected() {
        when(userRepository.findByIdAndOrganizationIdAndBranchId(userId, organizationId, branchId))
                .thenReturn(Optional.empty());
        var request = new UserStatusRequest(false);

        assertThatThrownBy(() -> userService.updateStatus(organizationId, branchId, userId, request))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("User not found");
    }

    @Test
    void statusSucceeds() {
        when(userRepository.findByIdAndOrganizationIdAndBranchId(userId, organizationId, branchId))
                .thenReturn(Optional.of(existingUser()));
        when(userRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        var request = new UserStatusRequest(false);

        UserStatusResponse response = userService.updateStatus(organizationId, branchId, userId, request);

        assertThat(response.id()).isEqualTo(userId);
        assertThat(response.isActive()).isFalse();
        verify(userRepository).save(any());
    }
}
