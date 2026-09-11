package com.x46.backend.security;

import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.json.JsonMapper;

/**
 * Writes one audit_logs row per create/update/status-change. organization_id
 * /branch_id/user_id come from the current request's JwtPrincipal (chunk
 * 0.3), not caller-supplied params, so every future service method only has
 * to say what happened, not who/where.
 */
@Service
public class AuditLogService {

    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper = JsonMapper.builder().build();

    public AuditLogService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void record(String actionType, String entityType, UUID entityId, Object oldValues, Object newValues) {
        JwtPrincipal principal = currentPrincipal();
        jdbcTemplate.update(
                "INSERT INTO audit_logs "
                        + "(organization_id, branch_id, user_id, action_type, entity_type, entity_id, old_values, new_values) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?::jsonb, ?::jsonb)",
                principal.organizationId(), principal.branchId(), principal.userId(),
                actionType, entityType, entityId, toJson(oldValues), toJson(newValues));
    }

    private JwtPrincipal currentPrincipal() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof JwtPrincipal principal) {
            return principal;
        }
        throw new IllegalStateException("Audit log requires an authenticated request");
    }

    private String toJson(Object value) {
        return value == null ? null : objectMapper.writeValueAsString(value);
    }
}
