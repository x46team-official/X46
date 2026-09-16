package com.x46.backend.org.dto;

public record CreateOrganizationRequest(String organizationName, String organizationCode, Boolean isActive) {
}
