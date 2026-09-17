package com.x46.backend.master.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record TestListItemResponse(
        UUID id,
        String testCode,
        String testName,
        UUID departmentId,
        BigDecimal sellingPrice,
        BigDecimal costPrice,
        boolean isActive) {
}
