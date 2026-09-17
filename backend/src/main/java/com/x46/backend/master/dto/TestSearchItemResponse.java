package com.x46.backend.master.dto;

import java.util.UUID;

public record TestSearchItemResponse(UUID id, String testCode, String testName, boolean isActive) {
}
