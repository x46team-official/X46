package com.x46.backend.org;

import java.util.UUID;

/** Shape for Activate/Deactivate Role (API-129), mirroring API-128's Activate/Deactivate User response. */
public record RoleStatusResponse(UUID id, boolean isActive) {
}
