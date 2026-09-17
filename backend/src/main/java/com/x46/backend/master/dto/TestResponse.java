package com.x46.backend.master.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record TestResponse(
        UUID id,
        UUID organizationId,
        UUID branchId,
        UUID departmentId,
        String testCode,
        String testName,
        BigDecimal sellingPrice,
        BigDecimal costPrice,
        BigDecimal cprr,
        boolean isActive) {
}
