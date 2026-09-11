package com.x46.backend.org;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
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
 * Full-stack coverage for API-003 (Create Role) and API-129 (List/View/Update/Status)
 * against the real dockerized Postgres, including the V43 roles.is_active migration.
 */
@SpringBootTest
@AutoConfigureMockMvc
class RoleIntegrationTest {

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
    private final UUID userId = UUID.randomUUID();
    private final UUID noPermUserId = UUID.randomUUID();

    @BeforeEach
    void seed() {
        jdbcTemplate.update(
                "INSERT INTO organizations (id, organization_code, organization_name) VALUES (?, ?, ?)",
                orgId, "ROLEIT", "Role IT Org");
        jdbcTemplate.update(
                "INSERT INTO branches (id, organization_id, branch_code, branch_name) VALUES (?, ?, ?, ?)",
                branchId, orgId, "BR1", "Role IT Branch");
        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                actorRoleId, orgId, branchId, "ACTOR", "Actor Role");
        jdbcTemplate.update(
                "INSERT INTO role_permission (organization_id, branch_id, role_id, module_name, "
                        + "can_create, can_view, can_update) VALUES (?, ?, ?, 'Role Management', TRUE, TRUE, TRUE)",
                orgId, branchId, actorRoleId);
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                userId, orgId, branchId, "role-actor", passwordEncoder.encode("secret123"), "Actor");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, userId, actorRoleId);

        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                noPermRoleId, orgId, branchId, "NOPERM", "No Permission Role");
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                noPermUserId, orgId, branchId, "role-no-perm", passwordEncoder.encode("secret123"), "NoPerm");
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

    private String loginAsActor() throws Exception {
        String body = "{\"organizationCode\":\"ROLEIT\",\"branchCode\":\"BR1\","
                + "\"username\":\"role-actor\",\"password\":\"secret123\"}";
        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.token");
    }

    private String loginAsNoPermUser() throws Exception {
        String body = "{\"organizationCode\":\"ROLEIT\",\"branchCode\":\"BR1\","
                + "\"username\":\"role-no-perm\",\"password\":\"secret123\"}";
        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.token");
    }

    private String rolesUrl() {
        return "/api/organizations/" + orgId + "/branches/" + branchId + "/roles";
    }

    private String createRoleReturningId(String token, String roleCode) throws Exception {
        String body = "{\"roleCode\":\"" + roleCode + "\",\"roleName\":\"" + roleCode + " Role\"}";
        String response = mockMvc.perform(post(rolesUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.id");
    }

    @Test
    void authorizedUserCanCreateRole() throws Exception {
        String token = loginAsActor();
        String body = "{\"roleCode\":\"TECH1\",\"roleName\":\"Technician\"}";

        mockMvc.perform(post(rolesUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.message").value("Role created successfully"))
                .andExpect(jsonPath("$.data.organizationId").value(orgId.toString()))
                .andExpect(jsonPath("$.data.branchId").value(branchId.toString()))
                .andExpect(jsonPath("$.data.roleCode").value("TECH1"));
    }

    @Test
    void createMissingRoleCodeReturns400() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(post(rolesUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"roleName\":\"Technician\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("roleCode is required"));
    }

    @Test
    void createUnknownBranchReturns404() throws Exception {
        String token = loginAsActor();
        String body = "{\"roleCode\":\"TECH2\",\"roleName\":\"Technician\"}";

        mockMvc.perform(post("/api/organizations/" + orgId + "/branches/" + UUID.randomUUID() + "/roles")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Organization or branch not found"));
    }

    @Test
    void createDuplicateRoleCodeReturns409() throws Exception {
        String token = loginAsActor();
        String body = "{\"roleCode\":\"TECH3\",\"roleName\":\"Technician\"}";
        mockMvc.perform(post(rolesUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated());

        mockMvc.perform(post(rolesUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("Duplicate role code"));
    }

    @Test
    void listRolesReturnsSeededRoles() throws Exception {
        String token = loginAsActor();
        createRoleReturningId(token, "TECH4");

        mockMvc.perform(get(rolesUrl()).header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Roles fetched successfully"));
    }

    @Test
    void listRolesWithSearchFiltersResults() throws Exception {
        String token = loginAsActor();
        createRoleReturningId(token, "TECH4B");

        mockMvc.perform(get(rolesUrl() + "?search=tech4b").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].roleCode").value("TECH4B"));
    }

    @Test
    void viewRoleReturns200() throws Exception {
        String token = loginAsActor();
        String roleId = createRoleReturningId(token, "TECH5");

        mockMvc.perform(get(rolesUrl() + "/" + roleId).header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.roleCode").value("TECH5"));
    }

    @Test
    void viewUnknownRoleReturns404() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(get(rolesUrl() + "/" + UUID.randomUUID())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Role not found"));
    }

    @Test
    void updateRoleReturns200() throws Exception {
        String token = loginAsActor();
        String roleId = createRoleReturningId(token, "TECH6");

        mockMvc.perform(put(rolesUrl() + "/" + roleId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"roleCode\":\"TECH6\",\"roleName\":\"Technician Updated\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.roleName").value("Technician Updated"));
    }

    @Test
    void updateUnknownRoleReturns404() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(put(rolesUrl() + "/" + UUID.randomUUID())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"roleCode\":\"TECH7\",\"roleName\":\"Technician\"}"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Role not found"));
    }

    @Test
    void statusUpdateReturns200() throws Exception {
        String token = loginAsActor();
        String roleId = createRoleReturningId(token, "TECH8");

        mockMvc.perform(patch(rolesUrl() + "/" + roleId + "/status")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"isActive\":false}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Role status updated successfully"))
                .andExpect(jsonPath("$.data.isActive").value(false));
    }

    @Test
    void statusUpdateMissingIsActiveReturns400() throws Exception {
        String token = loginAsActor();
        String roleId = createRoleReturningId(token, "TECH9");

        mockMvc.perform(patch(rolesUrl() + "/" + roleId + "/status")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Invalid status value"));
    }

    @Test
    void nonPermittedCallerIsForbidden() throws Exception {
        String token = loginAsNoPermUser();

        mockMvc.perform(post(rolesUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"roleCode\":\"TECH10\",\"roleName\":\"Technician\"}"))
                .andExpect(status().isForbidden());
    }

    @Test
    void missingTokenIsUnauthorized() throws Exception {
        mockMvc.perform(get(rolesUrl())).andExpect(status().isUnauthorized());
    }
}
