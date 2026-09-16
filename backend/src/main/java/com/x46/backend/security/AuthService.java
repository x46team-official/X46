package com.x46.backend.security;

import com.x46.backend.common.UnauthorizedException;
import java.util.List;
import java.util.UUID;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private static final String INVALID_CREDENTIALS = "Invalid credentials";

    private final AuthLookupRepository authLookupRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    AuthService(AuthLookupRepository authLookupRepository, PasswordEncoder passwordEncoder, JwtService jwtService) {
        this.authLookupRepository = authLookupRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    public LoginResponse login(LoginRequest request) {
        UUID organizationId;
        UUID branchId;
        UUID userId;
        String passwordHash;
        boolean active;

        if (isBlank(request.organizationCode()) && isBlank(request.branchCode())) {
            // Single-field login (plan.md gap #8): safe only because V44 made
            // users.username globally unique.
            AuthLookupRepository.GlobalAuthUserRow user = authLookupRepository
                    .findUserByUsername(request.username())
                    .orElseThrow(AuthService::invalidCredentials);
            organizationId = user.organizationId();
            branchId = user.branchId();
            userId = user.id();
            passwordHash = user.passwordHash();
            active = user.active();
        } else {
            organizationId = authLookupRepository.findOrganizationId(request.organizationCode())
                    .orElseThrow(AuthService::invalidCredentials);
            branchId = authLookupRepository.findBranchId(organizationId, request.branchCode())
                    .orElseThrow(AuthService::invalidCredentials);
            AuthLookupRepository.AuthUserRow user = authLookupRepository
                    .findUser(organizationId, branchId, request.username())
                    .orElseThrow(AuthService::invalidCredentials);
            userId = user.id();
            passwordHash = user.passwordHash();
            active = user.active();
        }

        if (!active || !passwordEncoder.matches(request.password(), passwordHash)) {
            throw invalidCredentials();
        }

        List<UUID> roleIds = authLookupRepository.findRoleIds(userId);
        JwtPrincipal principal = new JwtPrincipal(userId, organizationId, branchId, roleIds);
        JwtService.IssuedToken issued = jwtService.issue(principal);
        List<String> roleCodes = authLookupRepository.findRoleCodes(roleIds);

        return new LoginResponse(
                issued.token(), issued.expiresAt(), userId, organizationId, branchId, roleIds, roleCodes);
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private static UnauthorizedException invalidCredentials() {
        return new UnauthorizedException(INVALID_CREDENTIALS);
    }
}
