package com.x46.backend.identity.controller;

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
 * Full-stack coverage for API-005 (Assign Role to User) against the real
 * dockerized Postgres.
 */
@SpringBootTest
@AutoConfigureMockMvc
class UserRoleIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private final UUID orgId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();
    private final UUID actorRoleId = UUID.randomUUID();
    private final UUID noPermRoleId = UUID.randomUUID();
    private final UUID targetRoleId = UUID.randomUUID();
    private final UUID actorUserId = UUID.randomUUID();
    private final UUID noPermUserId = UUID.randomUUID();
    private final UUID targetUserId = UUID.randomUUID();

    @BeforeEach
    void seed() {
        jdbcTemplate.update(
                "INSERT INTO organizations (id, organization_code, organization_name) VALUES (?, ?, ?)",
                orgId, "USERROLEIT", "User Role IT Org");
        jdbcTemplate.update(
                "INSERT INTO branches (id, organization_id, branch_code, branch_name) VALUES (?, ?, ?, ?)",
                branchId, orgId, "BR1", "User Role IT Branch");
        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                actorRoleId, orgId, branchId, "ACTOR", "Actor Role");
        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                targetRoleId, orgId, branchId, "TARGET", "Target Role");
        jdbcTemplate.update(
                "INSERT INTO role_permission (organization_id, branch_id, role_id, module_name, "
                        + "can_create, can_view, can_update) VALUES (?, ?, ?, 'User Role Management', TRUE, TRUE, TRUE)",
                orgId, branchId, actorRoleId);
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                actorUserId, orgId, branchId, "ur-actor", passwordEncoder.encode("secret123"), "Actor");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, actorUserId, actorRoleId);
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                targetUserId, orgId, branchId, "ur-target", passwordEncoder.encode("secret123"), "Target");

        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                noPermRoleId, orgId, branchId, "NOPERM", "No Permission Role");
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                noPermUserId, orgId, branchId, "ur-no-perm", passwordEncoder.encode("secret123"), "NoPerm");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, noPermUserId, noPermRoleId);
    }

    @AfterEach
    void cleanUp() {
        jdbcTemplate.update("DELETE FROM role_permission WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM user_roles WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM users WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM roles WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM branches WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM organizations WHERE id = ?", orgId);
    }

    private String login(String username) throws Exception {
        String body = "{\"organizationCode\":\"USERROLEIT\",\"branchCode\":\"BR1\","
                + "\"username\":\"" + username + "\",\"password\":\"secret123\"}";
        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.token");
    }

    private String assignUrl(UUID userId) {
        return "/api/organizations/" + orgId + "/branches/" + branchId + "/users/" + userId + "/roles";
    }

    @Test
    void authorizedUserCanAssignRole() throws Exception {
        String token = login("ur-actor");

        mockMvc.perform(post(assignUrl(targetUserId))
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"roleId\":\"" + targetRoleId + "\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.message").value("User role assigned successfully"))
                .andExpect(jsonPath("$.data.organizationId").value(orgId.toString()))
                .andExpect(jsonPath("$.data.branchId").value(branchId.toString()))
                .andExpect(jsonPath("$.data.userId").value(targetUserId.toString()))
                .andExpect(jsonPath("$.data.roleId").value(targetRoleId.toString()));
    }

    @Test
    void unknownUserReturns404() throws Exception {
        String token = login("ur-actor");

        mockMvc.perform(post(assignUrl(UUID.randomUUID()))
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"roleId\":\"" + targetRoleId + "\"}"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("User not found"));
    }

    @Test
    void unknownRoleReturns404() throws Exception {
        String token = login("ur-actor");

        mockMvc.perform(post(assignUrl(targetUserId))
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"roleId\":\"" + UUID.randomUUID() + "\"}"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Role not found"));
    }

    @Test
    void unknownBranchReturns404() throws Exception {
        String token = login("ur-actor");

        mockMvc.perform(post("/api/organizations/" + orgId + "/branches/" + UUID.randomUUID()
                                + "/users/" + targetUserId + "/roles")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"roleId\":\"" + targetRoleId + "\"}"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Organization or branch not found"));
    }

    @Test
    void duplicateAssignmentReturns409() throws Exception {
        String token = login("ur-actor");
        String body = "{\"roleId\":\"" + targetRoleId + "\"}";
        mockMvc.perform(post(assignUrl(targetUserId))
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated());

        mockMvc.perform(post(assignUrl(targetUserId))
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("Role already assigned to user"));
    }

    @Test
    void nonPermittedCallerIsForbidden() throws Exception {
        String token = login("ur-no-perm");

        mockMvc.perform(post(assignUrl(targetUserId))
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"roleId\":\"" + targetRoleId + "\"}"))
                .andExpect(status().isForbidden());
    }

    @Test
    void missingTokenIsUnauthorized() throws Exception {
        mockMvc.perform(post(assignUrl(targetUserId))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"roleId\":\"" + targetRoleId + "\"}"))
                .andExpect(status().isUnauthorized());
    }
}
