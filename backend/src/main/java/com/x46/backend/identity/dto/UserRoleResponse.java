package com.x46.backend.identity.dto;

import java.time.OffsetDateTime;
import java.util.UUID;

/** Shape for Assign Role to User (API-005). */
public record UserRoleResponse(
        UUID organizationId, UUID branchId, UUID userId, UUID roleId, OffsetDateTime assignedAt) {
}
