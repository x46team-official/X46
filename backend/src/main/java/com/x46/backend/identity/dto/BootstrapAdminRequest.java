package com.x46.backend.identity.dto;

public record BootstrapAdminRequest(
        String username, String email, String password, String firstName, String lastName) {
}
