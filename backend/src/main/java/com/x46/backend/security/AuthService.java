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
        UUID organizationId = authLookupRepository.findOrganizationId(request.organizationCode())
                .orElseThrow(AuthService::invalidCredentials);
        UUID branchId = authLookupRepository.findBranchId(organizationId, request.branchCode())
                .orElseThrow(AuthService::invalidCredentials);
        AuthLookupRepository.AuthUserRow user = authLookupRepository
                .findUser(organizationId, branchId, request.username())
                .orElseThrow(AuthService::invalidCredentials);

        if (!user.active() || !passwordEncoder.matches(request.password(), user.passwordHash())) {
            throw invalidCredentials();
        }

        List<UUID> roleIds = authLookupRepository.findRoleIds(user.id());
        JwtPrincipal principal = new JwtPrincipal(user.id(), organizationId, branchId, roleIds);
        JwtService.IssuedToken issued = jwtService.issue(principal);

        return new LoginResponse(issued.token(), issued.expiresAt(), user.id(), organizationId, branchId, roleIds);
    }

    private static UnauthorizedException invalidCredentials() {
        return new UnauthorizedException(INVALID_CREDENTIALS);
    }
}
