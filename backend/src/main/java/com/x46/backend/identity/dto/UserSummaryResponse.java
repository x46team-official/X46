package com.x46.backend.identity.dto;

import java.util.UUID;

/** Shape for List Users items (API-128). */
public record UserSummaryResponse(
        UUID id, String username, String email, String firstName, String lastName, boolean isActive) {
}
