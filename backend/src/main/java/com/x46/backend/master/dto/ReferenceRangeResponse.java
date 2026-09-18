package com.x46.backend.master.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record ReferenceRangeResponse(
        UUID id,
        UUID parameterId,
        String gender,
        BigDecimal ageMin,
        BigDecimal ageMax,
        String ageUnit,
        boolean pregnancyFlag,
        BigDecimal referenceMin,
        BigDecimal referenceMax,
        LocalDate effectiveFrom) {
}
