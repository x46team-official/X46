package com.x46.backend.master.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record CreateTestRequest(
        UUID departmentId,
        String testCode,
        String testName,
        String displayName,
        String printName,
        String shortCode,
        BigDecimal sellingPrice,
        BigDecimal costPrice,
        BigDecimal cprr,
        UUID testCategoryId,
        UUID billingCategoryId,
        UUID sampleTypeId,
        UUID performingLabId,
        UUID outsourceCenterId,
        UUID worksheetId,
        UUID worklistId,
        String testMethod,
        String testType,
        Integer tatMinutes,
        String machineTestCode,
        String consumptionGroup,
        Boolean autoApproval,
        Boolean automaticallyAuthorize,
        Boolean nablAccredited,
        Boolean markAsProfile,
        Boolean twoStepVerification,
        Boolean authorizeOnlyByAuthorizer,
        Boolean outsourceTest,
        Boolean notifyAccession,
        String description) {
}
