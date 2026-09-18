package com.x46.backend.master.controller;

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
 * Full-stack coverage for API-012 (Create Department), API-013 (View Department),
 * API-014 (Update Department), and API-015 (Activate/Deactivate Department)
 * against the real dockerized Postgres.
 */
@SpringBootTest
@AutoConfigureMockMvc
class DepartmentIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private final UUID orgId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();
    private final UUID otherBranchId = UUID.randomUUID();
    private final UUID actorRoleId = UUID.randomUUID();
    private final UUID noPermRoleId = UUID.randomUUID();
    private final UUID userId = UUID.randomUUID();
    private final UUID noPermUserId = UUID.randomUUID();

    @BeforeEach
    void seed() {
        jdbcTemplate.update(
                "INSERT INTO organizations (id, organization_code, organization_name) VALUES (?, ?, ?)",
                orgId, "DEPTIT", "Department IT Org");
        jdbcTemplate.update(
                "INSERT INTO branches (id, organization_id, branch_code, branch_name) VALUES (?, ?, ?, ?)",
                branchId, orgId, "BR1", "Department IT Branch");
        jdbcTemplate.update(
                "INSERT INTO branches (id, organization_id, branch_code, branch_name) VALUES (?, ?, ?, ?)",
                otherBranchId, orgId, "BR2", "Department IT Other Branch");
        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                actorRoleId, orgId, branchId, "ACTOR", "Actor Role");
        jdbcTemplate.update(
                "INSERT INTO role_permission (organization_id, branch_id, role_id, module_name, "
                        + "can_create, can_view, can_update) VALUES (?, ?, ?, 'Department Management', TRUE, TRUE, TRUE)",
                orgId, branchId, actorRoleId);
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                userId, orgId, branchId, "dept-actor", passwordEncoder.encode("secret123"), "Actor");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, userId, actorRoleId);

        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                noPermRoleId, orgId, branchId, "NOPERM", "No Permission Role");
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                noPermUserId, orgId, branchId, "dept-no-perm", passwordEncoder.encode("secret123"), "NoPerm");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, noPermUserId, noPermRoleId);
    }

    @AfterEach
    void cleanUp() {
        jdbcTemplate.update("DELETE FROM department_master WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM role_permission WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM user_roles WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM users WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM roles WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM branches WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM organizations WHERE id = ?", orgId);
    }

    private String login(String username) throws Exception {
        String body = "{\"organizationCode\":\"DEPTIT\",\"branchCode\":\"BR1\","
                + "\"username\":\"" + username + "\",\"password\":\"secret123\"}";
        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.token");
    }

    private String departmentsUrl() {
        return "/api/organizations/" + orgId + "/branches/" + branchId + "/departments";
    }

    private static String body(String code, String name) {
        return "{\"departmentCode\":\"" + code + "\",\"departmentName\":\"" + name
                + "\",\"description\":\"" + name + " Department\"}";
    }

    private String createReturningId(String token, String code, String name) throws Exception {
        String response = mockMvc.perform(post(departmentsUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body(code, name)))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.id");
    }

    // --- create (API-012) ---

    @Test
    void authorizedUserCanCreateDepartment() throws Exception {
        String token = login("dept-actor");

        mockMvc.perform(post(departmentsUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body("BIO", "Biochemistry")))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.message").value("Department created successfully"))
                .andExpect(jsonPath("$.data.organizationId").value(orgId.toString()))
                .andExpect(jsonPath("$.data.branchId").value(branchId.toString()))
                .andExpect(jsonPath("$.data.departmentCode").value("BIO"))
                .andExpect(jsonPath("$.data.departmentName").value("Biochemistry"))
                .andExpect(jsonPath("$.data.isActive").value(true));
    }

    @Test
    void createMissingCodeReturns400() throws Exception {
        String token = login("dept-actor");

        mockMvc.perform(post(departmentsUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"departmentName\":\"Biochemistry\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Validation error"));
    }

    @Test
    void createUnknownBranchReturns404() throws Exception {
        String token = login("dept-actor");

        mockMvc.perform(post("/api/organizations/" + orgId + "/branches/" + UUID.randomUUID() + "/departments")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body("BIO", "Biochemistry")))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Organization or branch not found"));
    }

    @Test
    void createDuplicateCodeReturns409() throws Exception {
        String token = login("dept-actor");
        createReturningId(token, "BIO", "Biochemistry");

        mockMvc.perform(post(departmentsUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body("BIO", "Another Name")))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("Duplicate department code/name"));
    }

    // --- view (API-013) ---

    @Test
    void viewReturnsDepartmentWithDescription() throws Exception {
        String token = login("dept-actor");
        String id = createReturningId(token, "BIO", "Biochemistry");

        mockMvc.perform(get(departmentsUrl() + "/" + id).header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Department fetched successfully"))
                .andExpect(jsonPath("$.data.id").value(id))
                .andExpect(jsonPath("$.data.description").value("Biochemistry Department"))
                .andExpect(jsonPath("$.data.isActive").value(true));
    }

    @Test
    void viewDepartmentUnderAnotherBranchReturns404() throws Exception {
        String token = login("dept-actor");
        String id = createReturningId(token, "BIO", "Biochemistry");

        mockMvc.perform(get("/api/organizations/" + orgId + "/branches/" + otherBranchId + "/departments/" + id)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Department not found"));
    }

    @Test
    void viewMalformedIdReturns400() throws Exception {
        String token = login("dept-actor");

        mockMvc.perform(get(departmentsUrl() + "/not-a-uuid").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Invalid request"));
    }

    // --- update (API-014) ---

    @Test
    void authorizedUserCanUpdateDepartment() throws Exception {
        String token = login("dept-actor");
        String id = createReturningId(token, "BIO", "Biochemistry");

        mockMvc.perform(put(departmentsUrl() + "/" + id)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"departmentCode\":\"BIO\",\"departmentName\":\"Biochemistry Updated\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Department updated successfully"))
                .andExpect(jsonPath("$.data.id").value(id))
                .andExpect(jsonPath("$.data.departmentName").value("Biochemistry Updated"))
                .andExpect(jsonPath("$.data.isActive").value(true));
    }

    @Test
    void updateCollidingNameReturns409() throws Exception {
        String token = login("dept-actor");
        createReturningId(token, "HEM", "Haematology");
        String id = createReturningId(token, "BIO", "Biochemistry");

        mockMvc.perform(put(departmentsUrl() + "/" + id)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"departmentCode\":\"BIO\",\"departmentName\":\"Haematology\"}"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("Duplicate department code/name"));
    }

    @Test
    void updateUnknownDepartmentReturns404() throws Exception {
        String token = login("dept-actor");

        mockMvc.perform(put(departmentsUrl() + "/" + UUID.randomUUID())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body("BIO", "Biochemistry")))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Department not found"));
    }

    @Test
    void updateMissingNameReturns400() throws Exception {
        String token = login("dept-actor");
        String id = createReturningId(token, "BIO", "Biochemistry");

        mockMvc.perform(put(departmentsUrl() + "/" + id)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"departmentCode\":\"BIO\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Validation error"));
    }

    // --- status (API-015) ---

    @Test
    void authorizedUserCanDeactivateDepartment() throws Exception {
        String token = login("dept-actor");
        String id = createReturningId(token, "BIO", "Biochemistry");

        mockMvc.perform(patch(departmentsUrl() + "/" + id + "/status")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"isActive\":false}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Department status updated successfully"))
                .andExpect(jsonPath("$.data.id").value(id))
                .andExpect(jsonPath("$.data.isActive").value(false));
    }

    @Test
    void statusMissingIsActiveReturns400() throws Exception {
        String token = login("dept-actor");
        String id = createReturningId(token, "BIO", "Biochemistry");

        mockMvc.perform(patch(departmentsUrl() + "/" + id + "/status")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Invalid status value"));
    }

    @Test
    void statusUnknownDepartmentReturns404() throws Exception {
        String token = login("dept-actor");

        mockMvc.perform(patch(departmentsUrl() + "/" + UUID.randomUUID() + "/status")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"isActive\":false}"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Department not found"));
    }

    // --- security ---

    @Test
    void nonPermittedCallerIsForbidden() throws Exception {
        String token = login("dept-no-perm");

        mockMvc.perform(post(departmentsUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body("BIO", "Biochemistry")))
                .andExpect(status().isForbidden());
    }

    @Test
    void missingTokenIsUnauthorized() throws Exception {
        mockMvc.perform(get(departmentsUrl() + "/" + UUID.randomUUID())).andExpect(status().isUnauthorized());
    }
}
