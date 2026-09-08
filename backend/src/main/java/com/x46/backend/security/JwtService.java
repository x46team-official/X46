package com.x46.backend.security;

import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.json.JsonMapper;

/**
 * Hand-rolled HS256 JWT issue/parse. Not a library because jjwt's Jackson
 * binding targets Jackson 2, and this app runs Jackson 3 (tools.jackson.*);
 * pulling it in would mean two Jackson major versions on the classpath for
 * something JDK's own Mac/Base64 already does in a few lines.
 */
@Service
public class JwtService {

    private static final String HEADER_JSON = "{\"alg\":\"HS256\",\"typ\":\"JWT\"}";
    private static final Base64.Encoder ENCODER = Base64.getUrlEncoder().withoutPadding();
    private static final Base64.Decoder DECODER = Base64.getUrlDecoder();

    private final ObjectMapper objectMapper = JsonMapper.builder().build();
    private final SecretKeySpec key;
    private final long expirationMinutes;

    public JwtService(
            @Value("${security.jwt.secret}") String secret,
            @Value("${security.jwt.expiration-minutes:60}") long expirationMinutes) {
        this.key = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        this.expirationMinutes = expirationMinutes;
    }

    public record IssuedToken(String token, Instant expiresAt) {
    }

    public IssuedToken issue(JwtPrincipal principal) {
        Instant now = Instant.now();
        Instant expiresAt = now.plusSeconds(expirationMinutes * 60);

        Map<String, Object> claims = new LinkedHashMap<>();
        claims.put("sub", principal.userId().toString());
        claims.put("org", principal.organizationId().toString());
        claims.put("branch", principal.branchId().toString());
        claims.put("roles", principal.roleIds().stream().map(UUID::toString).collect(Collectors.toList()));
        claims.put("iat", now.getEpochSecond());
        claims.put("exp", expiresAt.getEpochSecond());

        String headerB64 = ENCODER.encodeToString(HEADER_JSON.getBytes(StandardCharsets.UTF_8));
        String payloadB64 = ENCODER.encodeToString(objectMapper.writeValueAsBytes(claims));
        String signingInput = headerB64 + "." + payloadB64;
        String signatureB64 = ENCODER.encodeToString(sign(signingInput));

        return new IssuedToken(signingInput + "." + signatureB64, expiresAt);
    }

    public JwtPrincipal parse(String token) {
        String[] parts = token.split("\\.");
        if (parts.length != 3) {
            throw new JwtException("Invalid token");
        }

        String signingInput = parts[0] + "." + parts[1];
        byte[] expectedSignature = sign(signingInput);
        byte[] actualSignature;
        try {
            actualSignature = DECODER.decode(parts[2]);
        } catch (IllegalArgumentException ex) {
            throw new JwtException("Invalid token");
        }
        if (!MessageDigest.isEqual(expectedSignature, actualSignature)) {
            throw new JwtException("Invalid token");
        }

        Map<String, Object> claims;
        try {
            claims = objectMapper.readValue(DECODER.decode(parts[1]), new TypeReference<Map<String, Object>>() {
            });
        } catch (RuntimeException ex) {
            throw new JwtException("Invalid token");
        }

        long exp = ((Number) claims.get("exp")).longValue();
        if (Instant.now().getEpochSecond() >= exp) {
            throw new JwtException("Token expired");
        }

        List<?> rawRoles = (List<?>) claims.get("roles");
        List<UUID> roleIds = rawRoles.stream().map(role -> UUID.fromString((String) role)).collect(Collectors.toList());

        return new JwtPrincipal(
                UUID.fromString((String) claims.get("sub")),
                UUID.fromString((String) claims.get("org")),
                UUID.fromString((String) claims.get("branch")),
                roleIds);
    }

    private byte[] sign(String input) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(key);
            return mac.doFinal(input.getBytes(StandardCharsets.UTF_8));
        } catch (GeneralSecurityException ex) {
            throw new IllegalStateException("Unable to sign JWT", ex);
        }
    }
}
