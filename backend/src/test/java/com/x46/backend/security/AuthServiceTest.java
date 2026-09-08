package com.x46.backend.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

import com.x46.backend.common.UnauthorizedException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    private static final UUID ORG_ID = UUID.randomUUID();
    private static final UUID BRANCH_ID = UUID.randomUUID();
    private static final UUID USER_ID = UUID.randomUUID();

    @Mock
    private AuthLookupRepository authLookupRepository;

    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService(authLookupRepository, passwordEncoder, new JwtService("test-secret-key-at-least-32-bytes-long!!", 60));
    }

    private static LoginRequest request(String password) {
        return new LoginRequest("ORG1", "BR1", "jdoe", password);
    }

    @Test
    void validLoginReturnsToken() {
        when(authLookupRepository.findOrganizationId("ORG1")).thenReturn(Optional.of(ORG_ID));
        when(authLookupRepository.findBranchId(ORG_ID, "BR1")).thenReturn(Optional.of(BRANCH_ID));
        when(authLookupRepository.findUser(ORG_ID, BRANCH_ID, "jdoe"))
                .thenReturn(Optional.of(new AuthLookupRepository.AuthUserRow(USER_ID, passwordEncoder.encode("secret"), true)));
        when(authLookupRepository.findRoleIds(USER_ID)).thenReturn(List.of());

        LoginResponse response = authService.login(request("secret"));

        assertThat(response.token()).isNotBlank();
        assertThat(response.userId()).isEqualTo(USER_ID);
        assertThat(response.organizationId()).isEqualTo(ORG_ID);
        assertThat(response.branchId()).isEqualTo(BRANCH_ID);
    }

    @Test
    void wrongPasswordIsRejected() {
        when(authLookupRepository.findOrganizationId("ORG1")).thenReturn(Optional.of(ORG_ID));
        when(authLookupRepository.findBranchId(ORG_ID, "BR1")).thenReturn(Optional.of(BRANCH_ID));
        when(authLookupRepository.findUser(ORG_ID, BRANCH_ID, "jdoe"))
                .thenReturn(Optional.of(new AuthLookupRepository.AuthUserRow(USER_ID, passwordEncoder.encode("secret"), true)));

        assertInvalidCredentials(() -> authService.login(request("wrong")));
    }

    @Test
    void inactiveUserIsRejected() {
        when(authLookupRepository.findOrganizationId("ORG1")).thenReturn(Optional.of(ORG_ID));
        when(authLookupRepository.findBranchId(ORG_ID, "BR1")).thenReturn(Optional.of(BRANCH_ID));
        when(authLookupRepository.findUser(ORG_ID, BRANCH_ID, "jdoe"))
                .thenReturn(Optional.of(new AuthLookupRepository.AuthUserRow(USER_ID, passwordEncoder.encode("secret"), false)));

        assertInvalidCredentials(() -> authService.login(request("secret")));
    }

    @Test
    void unknownOrganizationIsRejectedWithoutLeakingWhichFieldWasWrong() {
        when(authLookupRepository.findOrganizationId("ORG1")).thenReturn(Optional.empty());

        assertInvalidCredentials(() -> authService.login(request("secret")));
    }

    @Test
    void unknownBranchIsRejected() {
        when(authLookupRepository.findOrganizationId("ORG1")).thenReturn(Optional.of(ORG_ID));
        when(authLookupRepository.findBranchId(ORG_ID, "BR1")).thenReturn(Optional.empty());

        assertInvalidCredentials(() -> authService.login(request("secret")));
    }

    @Test
    void unknownUsernameIsRejected() {
        when(authLookupRepository.findOrganizationId("ORG1")).thenReturn(Optional.of(ORG_ID));
        when(authLookupRepository.findBranchId(ORG_ID, "BR1")).thenReturn(Optional.of(BRANCH_ID));
        when(authLookupRepository.findUser(ORG_ID, BRANCH_ID, "jdoe")).thenReturn(Optional.empty());

        assertInvalidCredentials(() -> authService.login(request("secret")));
    }

    private static void assertInvalidCredentials(org.assertj.core.api.ThrowableAssert.ThrowingCallable callable) {
        assertThatThrownBy(callable)
                .isInstanceOf(UnauthorizedException.class)
                .hasMessage("Invalid credentials");
    }
}
