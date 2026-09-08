package com.x46.backend.security;

public class JwtException extends RuntimeException {

    public JwtException(String message) {
        super(message);
    }
}
