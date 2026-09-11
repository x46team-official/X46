package com.x46.backend.org;

import java.util.UUID;

/** Shape for Create Role (API-003): the only operation whose response carries organizationId/branchId. */
public record RoleResponse(UUID id, UUID organizationId, UUID branchId, String roleCode, String roleName) {
}
