package com.x46.backend.org;

import java.time.OffsetDateTime;
import java.util.UUID;

/** Shape for View Role (API-129): adds createdAt on top of the summary fields. */
public record RoleDetailResponse(UUID id, String roleCode, String roleName, OffsetDateTime createdAt) {
}
