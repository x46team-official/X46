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
 * Full-stack coverage for POST /api/organizations against the real dockerized
 * Postgres, including the V42 PLATFORM bootstrap seed this chunk added
 * (organizationCode=PLATFORM, branchCode=PLATFORM-01, username=platform_admin,
 * password=Platform@123) and a separately-seeded non-admin user to prove the
 * hasRole('PLATFORM_ADMIN') gate actually discriminates.
 */
@SpringBootTest
@AutoConfigureMockMvc
class OrganizationIntegrationTest {

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
                orgId, "ORGIT", "Org IT Org");
        jdbcTemplate.update(
                "INSERT INTO branches (id, organization_id, branch_code, branch_name) VALUES (?, ?, ?, ?)",
                branchId, orgId, "BR1", "Org IT Branch");
        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                roleId, orgId, branchId, "TECH", "Technician");
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                userId, orgId, branchId, "nonadmin", passwordEncoder.encode("secret123"), "Non");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, userId, roleId);
    }

    @AfterEach
    void cleanUp() {
        jdbcTemplate.update("DELETE FROM user_roles WHERE user_id = ?", userId);
        jdbcTemplate.update("DELETE FROM users WHERE id = ?", userId);
        jdbcTemplate.update("DELETE FROM roles WHERE id = ?", roleId);
        jdbcTemplate.update("DELETE FROM branches WHERE id = ?", branchId);
        jdbcTemplate.update("DELETE FROM organizations WHERE id = ?", orgId);
        jdbcTemplate.update("DELETE FROM organizations WHERE organization_code LIKE 'ORGIT-CREATED%'");
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
        String body = "{\"organizationCode\":\"ORGIT\",\"branchCode\":\"BR1\","
                + "\"username\":\"nonadmin\",\"password\":\"secret123\"}";
        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.token");
    }

    @Test
    void platformAdminCanCreateOrganization() throws Exception {
        String token = loginAsPlatformAdmin();
        String requestBody = "{\"organizationName\":\"X46 Diagnostics\",\"organizationCode\":\"ORGIT-CREATED-1\"}";

        mockMvc.perform(post("/api/organizations")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Organization created successfully"))
                .andExpect(jsonPath("$.data.organizationCode").value("ORGIT-CREATED-1"))
                .andExpect(jsonPath("$.data.organizationName").value("X46 Diagnostics"))
                .andExpect(jsonPath("$.data.isActive").value(true));
    }

    @Test
    void missingOrganizationNameReturns400() throws Exception {
        String token = loginAsPlatformAdmin();
        String requestBody = "{\"organizationCode\":\"ORGIT-CREATED-2\"}";

        mockMvc.perform(post("/api/organizations")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error").value("organizationName is required"));
    }

    @Test
    void missingOrganizationCodeReturns400() throws Exception {
        String token = loginAsPlatformAdmin();
        String requestBody = "{\"organizationName\":\"X46 Diagnostics\"}";

        mockMvc.perform(post("/api/organizations")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("organizationCode is required"));
    }

    @Test
    void duplicateOrganizationCodeReturns409() throws Exception {
        String token = loginAsPlatformAdmin();
        String requestBody = "{\"organizationName\":\"X46 Diagnostics\",\"organizationCode\":\"ORGIT-CREATED-3\"}";

        mockMvc.perform(post("/api/organizations")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isCreated());

        mockMvc.perform(post("/api/organizations")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("Duplicate organization code"));
    }

    @Test
    void nonPlatformAdminCallerIsForbidden() throws Exception {
        String token = loginAsNonAdmin();
        String requestBody = "{\"organizationName\":\"X46 Diagnostics\",\"organizationCode\":\"ORGIT-CREATED-4\"}";

        mockMvc.perform(post("/api/organizations")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isForbidden());
    }

    @Test
    void missingTokenIsUnauthorized() throws Exception {
        String requestBody = "{\"organizationName\":\"X46 Diagnostics\",\"organizationCode\":\"ORGIT-CREATED-5\"}";

        mockMvc.perform(post("/api/organizations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isUnauthorized());
    }
}
