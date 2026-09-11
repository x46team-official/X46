package com.x46.backend.org;

import java.util.UUID;

public record OrganizationResponse(UUID id, String organizationCode, String organizationName, boolean isActive) {
}
