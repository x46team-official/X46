package com.x46.backend.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class JwtServiceTest {

    private static final String SECRET = "test-secret-key-at-least-32-bytes-long!!";

    private final JwtService jwtService = new JwtService(SECRET, 60);

    @Test
    void issuedTokenParsesBackToTheSamePrincipal() {
        var principal = new JwtPrincipal(
                UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID(), List.of(UUID.randomUUID()));

        var issued = jwtService.issue(principal);
        var parsed = jwtService.parse(issued.token());

        assertThat(parsed).isEqualTo(principal);
    }

    @Test
    void tamperedTokenIsRejected() {
        var principal = new JwtPrincipal(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID(), List.of());
        var issued = jwtService.issue(principal);
        // Flip a character near the start (part of the signed header), not the last
        // character of the token: the tail of a base64url-encoded 32-byte HMAC-SHA256
        // signature has a couple of "don't care" padding bits, so mutating exactly the
        // last character sometimes decodes back to the same signature bytes.
        char original = issued.token().charAt(0);
        char replacement = original == 'e' ? 'f' : 'e';
        String tampered = replacement + issued.token().substring(1);

        assertThatThrownBy(() -> jwtService.parse(tampered)).isInstanceOf(JwtException.class);
    }

    @Test
    void expiredTokenIsRejected() {
        var alreadyExpired = new JwtService(SECRET, -1);
        var principal = new JwtPrincipal(UUID.randomUUID(), UUID.randomUUID(), UUID.randomUUID(), List.of());
        var issued = alreadyExpired.issue(principal);

        assertThatThrownBy(() -> alreadyExpired.parse(issued.token())).isInstanceOf(JwtException.class);
    }

    @Test
    void malformedTokenIsRejected() {
        assertThatThrownBy(() -> jwtService.parse("not-a-jwt")).isInstanceOf(JwtException.class);
    }
}
