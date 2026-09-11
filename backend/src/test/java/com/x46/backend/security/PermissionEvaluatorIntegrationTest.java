package com.x46.backend.security;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jayway.jsonpath.JsonPath;
import java.util.UUID;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootTest
@AutoConfigureMockMvc
@Import(PermissionEvaluatorIntegrationTest.TestOnlyController.class)
class PermissionEvaluatorIntegrationTest {

    @RestController
    static class TestOnlyController {

        @GetMapping("/test/billing")
        @PreAuthorize("@perm.can('Billing', 'CREATE')")
        String billing() {
            return "ok";
        }
    }

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private final UUID orgId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();
    private final UUID roleId = UUID.randomUUID();
    private final UUID userId = UUID.randomUUID();

    @BeforeEach
    void seed() {
        jdbcTemplate.update(
                "INSERT INTO organizations (id, organization_code, organization_name) VALUES (?, ?, ?)",
                orgId, "RBACIT", "RBAC IT Org");
        jdbcTemplate.update(
                "INSERT INTO branches (id, organization_id, branch_code, branch_name) VALUES (?, ?, ?, ?)",
                branchId, orgId, "BR1", "RBAC IT Branch");
        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                roleId, orgId, branchId, "TECH", "Technician");
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                userId, orgId, branchId, "permit", passwordEncoder.encode("secret123"), "Perm");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, userId, roleId);
    }

    @AfterEach
    void cleanUp() {
        jdbcTemplate.update("DELETE FROM role_permission WHERE role_id = ?", roleId);
        jdbcTemplate.update("DELETE FROM user_roles WHERE user_id = ?", userId);
        jdbcTemplate.update("DELETE FROM users WHERE id = ?", userId);
        jdbcTemplate.update("DELETE FROM roles WHERE id = ?", roleId);
        jdbcTemplate.update("DELETE FROM branches WHERE id = ?", branchId);
        jdbcTemplate.update("DELETE FROM organizations WHERE id = ?", orgId);
    }

    private void grantBillingCreate(boolean canCreate) {
        jdbcTemplate.update(
                "INSERT INTO role_permission (organization_id, branch_id, role_id, module_name, can_create) "
                        + "VALUES (?, ?, ?, 'Billing', ?)",
                orgId, branchId, roleId, canCreate);
    }

    private String login() throws Exception {
        String loginBody = "{\"organizationCode\":\"RBACIT\",\"branchCode\":\"BR1\","
                + "\"username\":\"permit\",\"password\":\"secret123\"}";
        String body = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(loginBody))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(body, "$.data.token");
    }

    @Test
    void grantedPermissionAllowsTheCall() throws Exception {
        grantBillingCreate(true);
        String token = login();

        mockMvc.perform(get("/test/billing").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk());
    }

    @Test
    void missingPermissionIsDeniedWith403() throws Exception {
        grantBillingCreate(false);
        String token = login();

        mockMvc.perform(get("/test/billing").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isForbidden());
    }
}
