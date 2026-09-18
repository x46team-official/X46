package com.x46.backend.master.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;
import org.springframework.format.annotation.DateTimeFormat;

public record ReferenceRangeLookupQuery(
        UUID parameterId,
        String gender,
        BigDecimal age,
        String ageUnit,
        Boolean pregnancyFlag,
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate asOfDate) {
}
