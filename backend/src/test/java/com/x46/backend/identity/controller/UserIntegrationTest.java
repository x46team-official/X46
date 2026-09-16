package com.x46.backend.identity.controller;

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
 * Full-stack coverage for API-004 (Create User) and API-128 (List/View/Update/Status)
 * against the real dockerized Postgres.
 */
@SpringBootTest
@AutoConfigureMockMvc
class UserIntegrationTest {

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
    private final UUID actorUserId = UUID.randomUUID();
    private final UUID noPermUserId = UUID.randomUUID();

    @BeforeEach
    void seed() {
        jdbcTemplate.update(
                "INSERT INTO organizations (id, organization_code, organization_name) VALUES (?, ?, ?)",
                orgId, "USERIT", "User IT Org");
        jdbcTemplate.update(
                "INSERT INTO branches (id, organization_id, branch_code, branch_name) VALUES (?, ?, ?, ?)",
                branchId, orgId, "BR1", "User IT Branch");
        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                actorRoleId, orgId, branchId, "ACTOR", "Actor Role");
        jdbcTemplate.update(
                "INSERT INTO role_permission (organization_id, branch_id, role_id, module_name, "
                        + "can_create, can_view, can_update) VALUES (?, ?, ?, 'User Management', TRUE, TRUE, TRUE)",
                orgId, branchId, actorRoleId);
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                actorUserId, orgId, branchId, "user-actor", passwordEncoder.encode("secret123"), "Actor");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, actorUserId, actorRoleId);

        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                noPermRoleId, orgId, branchId, "NOPERM", "No Permission Role");
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                noPermUserId, orgId, branchId, "user-no-perm", passwordEncoder.encode("secret123"), "NoPerm");
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
        return login("user-actor");
    }

    private String loginAsNoPermUser() throws Exception {
        return login("user-no-perm");
    }

    private String login(String username) throws Exception {
        String body = "{\"organizationCode\":\"USERIT\",\"branchCode\":\"BR1\","
                + "\"username\":\"" + username + "\",\"password\":\"secret123\"}";
        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.token");
    }

    private String usersUrl() {
        return "/api/organizations/" + orgId + "/branches/" + branchId + "/users";
    }

    private String createUserReturningId(String token, String username) throws Exception {
        String body = "{\"username\":\"" + username + "\",\"password\":\"secret123\",\"firstName\":\"Test\"}";
        String response = mockMvc.perform(post(usersUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.id");
    }

    @Test
    void authorizedUserCanCreateUser() throws Exception {
        String token = loginAsActor();
        String body = "{\"username\":\"newuser1\",\"email\":\"nu1@x46.com\","
                + "\"password\":\"secret123\",\"firstName\":\"New\",\"lastName\":\"User\"}";

        mockMvc.perform(post(usersUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.message").value("User created successfully"))
                .andExpect(jsonPath("$.data.organizationId").value(orgId.toString()))
                .andExpect(jsonPath("$.data.branchId").value(branchId.toString()))
                .andExpect(jsonPath("$.data.username").value("USERIT-newuser1"))
                .andExpect(jsonPath("$.data.isActive").value(true));
    }

    @Test
    void createMissingUsernameReturns400() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(post(usersUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"password\":\"secret123\",\"firstName\":\"New\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("username is required"));
    }

    @Test
    void createMissingPasswordReturns400() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(post(usersUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"username\":\"newuser2\",\"firstName\":\"New\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("password is required"));
    }

    @Test
    void createMissingFirstNameReturns400() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(post(usersUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"username\":\"newuser3\",\"password\":\"secret123\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("firstName is required"));
    }

    @Test
    void createUnknownBranchReturns404() throws Exception {
        String token = loginAsActor();
        String body = "{\"username\":\"newuser4\",\"password\":\"secret123\",\"firstName\":\"New\"}";

        mockMvc.perform(post("/api/organizations/" + orgId + "/branches/" + UUID.randomUUID() + "/users")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Organization or branch not found"));
    }

    @Test
    void createDuplicateUsernameReturns409() throws Exception {
        String token = loginAsActor();
        String body = "{\"username\":\"newuser5\",\"password\":\"secret123\",\"firstName\":\"New\"}";
        mockMvc.perform(post(usersUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated());

        mockMvc.perform(post(usersUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("Duplicate username"));
    }

    @Test
    void listUsersReturnsSeededUsers() throws Exception {
        String token = loginAsActor();
        createUserReturningId(token, "newuser6");

        mockMvc.perform(get(usersUrl()).header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Users fetched successfully"));
    }

    @Test
    void listUsersWithSearchFiltersResults() throws Exception {
        String token = loginAsActor();
        createUserReturningId(token, "findme7");

        mockMvc.perform(get(usersUrl() + "?search=findme7").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].username").value("USERIT-findme7"));
    }

    @Test
    void viewUserReturns200WithRoles() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(get(usersUrl() + "/" + actorUserId).header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.username").value("user-actor"))
                .andExpect(jsonPath("$.data.roles[0].roleCode").value("ACTOR"));
    }

    @Test
    void viewUnknownUserReturns404() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(get(usersUrl() + "/" + UUID.randomUUID())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("User not found"));
    }

    @Test
    void updateUserReturns200() throws Exception {
        String token = loginAsActor();
        String userId = createUserReturningId(token, "newuser8");

        mockMvc.perform(put(usersUrl() + "/" + userId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"updated@x46.com\",\"firstName\":\"Updated\",\"lastName\":\"Name\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.firstName").value("Updated"))
                .andExpect(jsonPath("$.data.lastName").value("Name"))
                .andExpect(jsonPath("$.data.email").value("updated@x46.com"));
    }

    @Test
    void updateMissingFirstNameReturns400() throws Exception {
        String token = loginAsActor();
        String userId = createUserReturningId(token, "newuser9");

        mockMvc.perform(put(usersUrl() + "/" + userId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"updated@x46.com\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("firstName is required"));
    }

    @Test
    void updateUnknownUserReturns404() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(put(usersUrl() + "/" + UUID.randomUUID())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"firstName\":\"Updated\"}"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("User not found"));
    }

    @Test
    void updateStatusReturns200() throws Exception {
        String token = loginAsActor();
        String userId = createUserReturningId(token, "newuser10");

        mockMvc.perform(patch(usersUrl() + "/" + userId + "/status")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"isActive\":false}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.isActive").value(false));
    }

    @Test
    void updateStatusMissingIsActiveReturns400() throws Exception {
        String token = loginAsActor();
        String userId = createUserReturningId(token, "newuser11");

        mockMvc.perform(patch(usersUrl() + "/" + userId + "/status")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Invalid status value"));
    }

    @Test
    void updateStatusUnknownUserReturns404() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(patch(usersUrl() + "/" + UUID.randomUUID() + "/status")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"isActive\":false}"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("User not found"));
    }

    @Test
    void createUserForbiddenWithoutPermission() throws Exception {
        String token = loginAsNoPermUser();

        mockMvc.perform(post(usersUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"username\":\"newuser12\",\"password\":\"secret123\",\"firstName\":\"New\"}"))
                .andExpect(status().isForbidden());
    }

    @Test
    void missingTokenIsUnauthorized() throws Exception {
        mockMvc.perform(get(usersUrl())).andExpect(status().isUnauthorized());
    }
}
