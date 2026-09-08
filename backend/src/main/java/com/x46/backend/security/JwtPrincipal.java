package com.x46.backend.security;

import java.util.List;
import java.util.UUID;

public record JwtPrincipal(UUID userId, UUID organizationId, UUID branchId, List<UUID> roleIds) {
}
