package com.x46.backend.identity.dto;

import java.util.UUID;

/** Shape for Create User (API-004). */
public record UserResponse(
        UUID id,
        UUID organizationId,
        UUID branchId,
        String username,
        String email,
        String firstName,
        String lastName,
        boolean isActive) {
}
