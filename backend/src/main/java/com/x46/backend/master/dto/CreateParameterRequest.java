package com.x46.backend.master.dto;

import java.util.UUID;

public record CreateParameterRequest(
        UUID organizationId,
        UUID branchId,
        String parameterCode,
        String parameterName,
        String unit,
        String defaultReferenceRange) {
}
