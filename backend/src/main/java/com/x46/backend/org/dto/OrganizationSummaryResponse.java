package com.x46.backend.org.dto;

import java.util.UUID;

public record OrganizationSummaryResponse(
        UUID id, String organizationCode, String organizationName, boolean isActive, long branchCount,
        long userCount) {
}
