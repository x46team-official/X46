package com.x46.backend.master.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record UpdateTestRequest(
        UUID departmentId,
        String testCode,
        String testName,
        BigDecimal sellingPrice,
        BigDecimal costPrice,
        BigDecimal cprr,
        String displayName,
        String printName,
        String shortCode,
        String testMethod,
        String testType,
        Integer tatMinutes,
        String description) {
}
