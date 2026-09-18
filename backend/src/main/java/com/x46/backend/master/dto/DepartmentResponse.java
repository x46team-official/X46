package com.x46.backend.master.dto;

import java.util.UUID;

public record DepartmentResponse(
        UUID id,
        UUID organizationId,
        UUID branchId,
        String departmentCode,
        String departmentName,
        Boolean isActive) {
}
