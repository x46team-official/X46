package com.x46.backend.master.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record CreateReferenceRangeRequest(
        UUID organizationId,
        UUID branchId,
        UUID parameterId,
        String gender,
        BigDecimal ageMin,
        BigDecimal ageMax,
        String ageUnit,
        Boolean pregnancyFlag,
        BigDecimal referenceMin,
        BigDecimal referenceMax,
        String referenceRange,
        BigDecimal criticalLow,
        BigDecimal criticalHigh,
        LocalDate effectiveFrom,
        LocalDate effectiveTo) {
}
