package com.x46.backend.identity.dto;

import java.util.UUID;

/** Shape for Update User (API-128 op3): id/firstName/lastName/email only. */
public record UserUpdateResponse(UUID id, String firstName, String lastName, String email) {
}
