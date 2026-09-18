package com.x46.backend.master.dto;

import java.util.UUID;

public record DepartmentUpdateResponse(UUID id, String departmentCode, String departmentName, Boolean isActive) {
}
