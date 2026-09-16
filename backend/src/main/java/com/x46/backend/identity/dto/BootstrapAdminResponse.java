package com.x46.backend.identity.dto;

import java.util.UUID;

public record BootstrapAdminResponse(
        UUID organizationId, UUID branchId, UUID roleId, String roleCode, UUID userId, String username) {
}
