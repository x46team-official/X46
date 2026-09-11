package com.x46.backend.security;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;

@SpringBootTest
class AuditLogServiceIntegrationTest {

    @Autowired
    private AuditLogService auditLogService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private final UUID orgId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();
    private final UUID userId = UUID.randomUUID();
    private final UUID roleId = UUID.randomUUID();
    private final UUID entityId = UUID.randomUUID();

    @BeforeEach
    void seed() {
        jdbcTemplate.update(
                "INSERT INTO organizations (id, organization_code, organization_name) VALUES (?, ?, ?)",
                orgId, "AUDITIT", "Audit IT Org");
        jdbcTemplate.update(
                "INSERT INTO branches (id, organization_id, branch_code, branch_name) VALUES (?, ?, ?, ?)",
                branchId, orgId, "BR1", "Audit IT Branch");
        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                roleId, orgId, branchId, "TECH", "Technician");
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, 'x', 'Audit', TRUE)",
                userId, orgId, branchId, "audituser");

        JwtPrincipal principal = new JwtPrincipal(userId, orgId, branchId, List.of(roleId));
        SecurityContextHolder.getContext()
                .setAuthentication(new UsernamePasswordAuthenticationToken(principal, null, List.of()));
    }

    @AfterEach
    void cleanUp() {
        SecurityContextHolder.clearContext();
        jdbcTemplate.update("DELETE FROM audit_logs WHERE entity_id = ?", entityId);
        jdbcTemplate.update("DELETE FROM users WHERE id = ?", userId);
        jdbcTemplate.update("DELETE FROM roles WHERE id = ?", roleId);
        jdbcTemplate.update("DELETE FROM branches WHERE id = ?", branchId);
        jdbcTemplate.update("DELETE FROM organizations WHERE id = ?", orgId);
    }

    @Test
    void createThenUpdateWritesTwoAuditRows() {
        auditLogService.record("CREATE", "Patient", entityId, null, Map.of("name", "Jane"));
        auditLogService.record("UPDATE", "Patient", entityId, Map.of("name", "Jane"), Map.of("name", "Jane Doe"));

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                "SELECT * FROM audit_logs WHERE entity_id = ? ORDER BY created_at", entityId);

        assertThat(rows).hasSize(2);
        assertThat(rows.get(0).get("action_type")).isEqualTo("CREATE");
        assertThat(rows.get(0).get("organization_id")).isEqualTo(orgId);
        assertThat(rows.get(0).get("branch_id")).isEqualTo(branchId);
        assertThat(rows.get(0).get("user_id")).isEqualTo(userId);
        assertThat(rows.get(0).get("old_values")).isNull();
        assertThat(rows.get(0).get("new_values").toString()).contains("Jane");

        assertThat(rows.get(1).get("action_type")).isEqualTo("UPDATE");
        assertThat(rows.get(1).get("old_values").toString()).contains("Jane");
        assertThat(rows.get(1).get("new_values").toString()).contains("Jane Doe");
    }
}
