package com.x46.backend.org;

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
 * Full-stack coverage for POST /api/organizations/{organizationId}/branches
 * against the real dockerized Postgres, reusing the V42 PLATFORM bootstrap
 * seed for the admin token, same as OrganizationIntegrationTest (Chunk 1.1).
 */
@SpringBootTest
@AutoConfigureMockMvc
class BranchIntegrationTest {

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
    void seedNonAdminUser() {
        jdbcTemplate.update(
                "INSERT INTO organizations (id, organization_code, organization_name) VALUES (?, ?, ?)",
                orgId, "BRANCHIT", "Branch IT Org");
        jdbcTemplate.update(
                "INSERT INTO branches (id, organization_id, branch_code, branch_name) VALUES (?, ?, ?, ?)",
                branchId, orgId, "BR1", "Branch IT Branch");
        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                roleId, orgId, branchId, "TECH", "Technician");
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                userId, orgId, branchId, "nonadmin-branch", passwordEncoder.encode("secret123"), "Non");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, userId, roleId);
    }

    @AfterEach
    void cleanUp() {
        jdbcTemplate.update("DELETE FROM user_roles WHERE user_id = ?", userId);
        jdbcTemplate.update("DELETE FROM users WHERE id = ?", userId);
        jdbcTemplate.update("DELETE FROM roles WHERE id = ?", roleId);
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
        String body = "{\"organizationCode\":\"BRANCHIT\",\"branchCode\":\"BR1\","
                + "\"username\":\"nonadmin-branch\",\"password\":\"secret123\"}";
        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.token");
    }

    @Test
    void platformAdminCanCreateBranch() throws Exception {
        String token = loginAsPlatformAdmin();
        String requestBody = "{\"branchCode\":\"PUNE-01\",\"branchName\":\"Pune Main Branch\"}";

        mockMvc.perform(post("/api/organizations/{organizationId}/branches", orgId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Branch created successfully"))
                .andExpect(jsonPath("$.data.organizationId").value(orgId.toString()))
                .andExpect(jsonPath("$.data.branchCode").value("PUNE-01"))
                .andExpect(jsonPath("$.data.branchName").value("Pune Main Branch"))
                .andExpect(jsonPath("$.data.isActive").value(true));
    }

    @Test
    void missingBranchCodeReturns400() throws Exception {
        String token = loginAsPlatformAdmin();
        String requestBody = "{\"branchName\":\"Pune Main Branch\"}";

        mockMvc.perform(post("/api/organizations/{organizationId}/branches", orgId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error").value("branchCode is required"));
    }

    @Test
    void missingBranchNameReturns400() throws Exception {
        String token = loginAsPlatformAdmin();
        String requestBody = "{\"branchCode\":\"PUNE-02\"}";

        mockMvc.perform(post("/api/organizations/{organizationId}/branches", orgId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("branchName is required"));
    }

    @Test
    void unknownOrganizationReturns404() throws Exception {
        String token = loginAsPlatformAdmin();
        String requestBody = "{\"branchCode\":\"PUNE-03\",\"branchName\":\"Pune Main Branch\"}";

        mockMvc.perform(post("/api/organizations/{organizationId}/branches", UUID.randomUUID())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Organization not found"));
    }

    @Test
    void duplicateBranchCodeReturns409() throws Exception {
        String token = loginAsPlatformAdmin();
        String requestBody = "{\"branchCode\":\"PUNE-04\",\"branchName\":\"Pune Main Branch\"}";

        mockMvc.perform(post("/api/organizations/{organizationId}/branches", orgId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isCreated());

        mockMvc.perform(post("/api/organizations/{organizationId}/branches", orgId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("Duplicate branch code"));
    }

    @Test
    void nonPlatformAdminCallerIsForbidden() throws Exception {
        String token = loginAsNonAdmin();
        String requestBody = "{\"branchCode\":\"PUNE-05\",\"branchName\":\"Pune Main Branch\"}";

        mockMvc.perform(post("/api/organizations/{organizationId}/branches", orgId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isForbidden());
    }

    @Test
    void missingTokenIsUnauthorized() throws Exception {
        String requestBody = "{\"branchCode\":\"PUNE-06\",\"branchName\":\"Pune Main Branch\"}";

        mockMvc.perform(post("/api/organizations/{organizationId}/branches", orgId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isUnauthorized());
    }
}
