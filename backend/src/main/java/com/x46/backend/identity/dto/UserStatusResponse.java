package com.x46.backend.identity.dto;

import java.util.UUID;

/** Shape for Activate/Deactivate User (API-128 op4). */
public record UserStatusResponse(UUID id, boolean isActive) {
}
