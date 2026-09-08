package com.x46.backend.security;

public record LoginRequest(String organizationCode, String branchCode, String username, String password) {
}
