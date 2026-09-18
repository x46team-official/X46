package com.x46.backend.master.dto;

import java.util.UUID;

public record ParameterResponse(
        UUID id, String parameterCode, String parameterName, String unit, String defaultReferenceRange) {
}
