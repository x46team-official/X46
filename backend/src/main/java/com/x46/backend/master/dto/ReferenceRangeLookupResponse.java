package com.x46.backend.master.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public record ReferenceRangeLookupResponse(
        BigDecimal referenceMin,
        BigDecimal referenceMax,
        String referenceRange,
        BigDecimal criticalLow,
        BigDecimal criticalHigh,
        LocalDate effectiveFrom,
        LocalDate effectiveTo) {
}
