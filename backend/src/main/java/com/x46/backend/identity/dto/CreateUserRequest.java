package com.x46.backend.identity.dto;

public record CreateUserRequest(
        String username, String email, String password, String firstName, String lastName, Boolean isActive) {
}
