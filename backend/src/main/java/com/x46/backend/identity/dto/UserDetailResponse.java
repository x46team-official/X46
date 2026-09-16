package com.x46.backend.identity.dto;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

/** Shape for View User (API-128): summary fields plus its assigned roles. */
public record UserDetailResponse(
        UUID id,
        String username,
        String email,
        String firstName,
        String lastName,
        boolean isActive,
        List<RoleAssignment> roles) {

    public record RoleAssignment(UUID roleId, String roleCode, String roleName, OffsetDateTime assignedAt) {
    }
}
