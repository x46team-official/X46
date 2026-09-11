package com.x46.backend.org;

public record CreateOrganizationRequest(String organizationName, String organizationCode, Boolean isActive) {
}
