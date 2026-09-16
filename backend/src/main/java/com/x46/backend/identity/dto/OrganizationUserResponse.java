package com.x46.backend.identity.dto;

import java.util.UUID;

/** Cross-branch user listing for the platform-admin dashboard (plan.md gap #7, Chunk 1.8). */
public record OrganizationUserResponse(
        UUID id,
        UUID branchId,
        String branchCode,
        String username,
        String email,
        String firstName,
        String lastName,
        boolean isActive) {
}
