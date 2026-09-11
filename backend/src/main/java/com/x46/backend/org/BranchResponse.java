package com.x46.backend.org;

import java.util.UUID;

public record BranchResponse(UUID id, UUID organizationId, String branchCode, String branchName, boolean isActive) {
}
