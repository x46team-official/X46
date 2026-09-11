package com.x46.backend.org;

import java.util.UUID;

/** Shape shared by List Roles (item) and Update Role (API-129) - both are exactly id/roleCode/roleName. */
public record RoleSummaryResponse(UUID id, String roleCode, String roleName) {
}
