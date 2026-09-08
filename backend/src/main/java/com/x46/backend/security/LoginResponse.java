package com.x46.backend.security;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record LoginResponse(
        String token,
        Instant expiresAt,
        UUID userId,
        UUID organizationId,
        UUID branchId,
        List<UUID> roles) {
}
