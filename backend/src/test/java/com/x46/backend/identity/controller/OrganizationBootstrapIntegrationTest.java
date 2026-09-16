package com.x46.backend.identity.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.jayway.jsonpath.JsonPath;
import java.util.UUID;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;

/**
 * Full-stack coverage for POST .../bootstrap-admin (plan.md gap #7, Chunk
 * 1.7) against the real dockerized Postgres.
 */
@SpringBootTest
@AutoConfigureMockMvc
class OrganizationBootstrapIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private final UUID orgId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();
    private final UUID nonAdminRoleId = UUID.randomUUID();
    private final UUID nonAdminUserId = UUID.randomUUID();

    @BeforeEach
    void seed() {
        jdbcTemplate.update(
                "INSERT INTO organizations (id, organization_code, organization_name) VALUES (?, ?, ?)",
                orgId, "BOOTSTRAPIT", "Bootstrap IT Org");
        jdbcTemplate.update(
                "INSERT INTO branches (id, organization_id, branch_code, branch_name) VALUES (?, ?, ?, ?)",
                branchId, orgId, "BR1", "Bootstrap IT Branch");
        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                nonAdminRoleId, orgId, branchId, "TECH", "Technician");
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                nonAdminUserId, orgId, branchId, "bootstrap-nonadmin", passwordEncoder.encode("secret123"), "Non");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, nonAdminUserId, nonAdminRoleId);
    }

    @AfterEach
    void cleanUp() {
        jdbcTemplate.update(
                "DELETE FROM user_roles WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM role_permission WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM users WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM roles WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM branches WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM organizations WHERE id = ?", orgId);
    }

    private String loginAsPlatformAdmin() throws Exception {
        String body = "{\"organizationCode\":\"PLATFORM\",\"branchCode\":\"PLATFORM-01\","
                + "\"username\":\"platform_admin\",\"password\":\"Platform@123\"}";
        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.token");
    }

    private String loginAsNonAdmin() throws Exception {
        String body = "{\"organizationCode\":\"BOOTSTRAPIT\",\"branchCode\":\"BR1\","
                + "\"username\":\"bootstrap-nonadmin\",\"password\":\"secret123\"}";
        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.token");
    }

    private String bootstrapUrl(UUID organizationId, UUID branchIdValue) {
        return "/api/organizations/" + organizationId + "/branches/" + branchIdValue + "/bootstrap-admin";
    }

    @Test
    void platformAdminCanBootstrapFirstAdminForNewOrg() throws Exception {
        String token = loginAsPlatformAdmin();
        String body = "{\"username\":\"bootstrap-admin\",\"email\":\"admin@bootstrapit.com\","
                + "\"password\":\"Secret@123\",\"firstName\":\"Org\",\"lastName\":\"Admin\"}";

        String response = mockMvc.perform(post(bootstrapUrl(orgId, branchId))
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.roleCode").value("ADMIN"))
                .andExpect(jsonPath("$.data.username").value("BOOTSTRAPIT-bootstrap-admin"))
                .andReturn().getResponse().getContentAsString();

        String roleId = JsonPath.read(response, "$.data.roleId");
        Integer permissionCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM role_permission WHERE role_id = ?", Integer.class, UUID.fromString(roleId));
        assertThat(permissionCount).isEqualTo(25);

        // the newly bootstrapped admin can actually log in with just the
        // (auto-prefixed) username + password - no org/branch code needed
        String loginBody = "{\"username\":\"BOOTSTRAPIT-bootstrap-admin\",\"password\":\"Secret@123\"}";
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(loginBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.token").exists());
    }

    @Test
    void missingUsernameReturns400() throws Exception {
        String token = loginAsPlatformAdmin();
        String body = "{\"password\":\"Secret@123\",\"firstName\":\"Org\"}";

        mockMvc.perform(post(bootstrapUrl(orgId, branchId))
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("username is required"));
    }

    @Test
    void unknownOrgOrBranchReturns404() throws Exception {
        String token = loginAsPlatformAdmin();
        String body = "{\"username\":\"bootstrap-admin\",\"password\":\"Secret@123\",\"firstName\":\"Org\"}";

        mockMvc.perform(post(bootstrapUrl(UUID.randomUUID(), UUID.randomUUID()))
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Organization or branch not found"));
    }

    @Test
    void secondBootstrapCallForSameOrgReturns409() throws Exception {
        String token = loginAsPlatformAdmin();
        String body = "{\"username\":\"bootstrap-admin\",\"password\":\"Secret@123\",\"firstName\":\"Org\"}";

        mockMvc.perform(post(bootstrapUrl(orgId, branchId))
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated());

        mockMvc.perform(post(bootstrapUrl(orgId, branchId))
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"username\":\"bootstrap-admin-2\",\"password\":\"Secret@123\",\"firstName\":\"Org\"}"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("Duplicate role code"));
    }

    @Test
    void nonPlatformAdminCallerIsForbidden() throws Exception {
        String token = loginAsNonAdmin();
        String body = "{\"username\":\"bootstrap-admin\",\"password\":\"Secret@123\",\"firstName\":\"Org\"}";

        mockMvc.perform(post(bootstrapUrl(orgId, branchId))
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isForbidden());
    }

    @Test
    void missingTokenIsUnauthorized() throws Exception {
        String body = "{\"username\":\"bootstrap-admin\",\"password\":\"Secret@123\",\"firstName\":\"Org\"}";

        mockMvc.perform(post(bootstrapUrl(orgId, branchId))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isUnauthorized());
    }
}
