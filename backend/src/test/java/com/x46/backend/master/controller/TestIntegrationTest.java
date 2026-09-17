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
 * Full-stack coverage for API-006 (Create Test), API-007 (View Test),
 * API-008 (Update Test), and API-009 (Activate/Deactivate Test) against the
 * real dockerized Postgres.
 */
@SpringBootTest
@AutoConfigureMockMvc
class TestIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private final UUID orgId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();
    private final UUID departmentId = UUID.randomUUID();
    private final UUID actorRoleId = UUID.randomUUID();
    private final UUID noPermRoleId = UUID.randomUUID();
    private final UUID userId = UUID.randomUUID();
    private final UUID noPermUserId = UUID.randomUUID();

    @BeforeEach
    void seed() {
        jdbcTemplate.update(
                "INSERT INTO organizations (id, organization_code, organization_name) VALUES (?, ?, ?)",
                orgId, "TESTIT", "Test IT Org");
        jdbcTemplate.update(
                "INSERT INTO branches (id, organization_id, branch_code, branch_name) VALUES (?, ?, ?, ?)",
                branchId, orgId, "BR1", "Test IT Branch");
        jdbcTemplate.update(
                "INSERT INTO department_master (id, organization_id, branch_id, department_name) VALUES (?, ?, ?, ?)",
                departmentId, orgId, branchId, "Biochemistry");
        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                actorRoleId, orgId, branchId, "ACTOR", "Actor Role");
        jdbcTemplate.update(
                "INSERT INTO role_permission (organization_id, branch_id, role_id, module_name, "
                        + "can_create, can_view, can_update) VALUES (?, ?, ?, 'Test Management', TRUE, TRUE, TRUE)",
                orgId, branchId, actorRoleId);
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                userId, orgId, branchId, "test-actor", passwordEncoder.encode("secret123"), "Actor");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, userId, actorRoleId);

        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                noPermRoleId, orgId, branchId, "NOPERM", "No Permission Role");
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                noPermUserId, orgId, branchId, "test-no-perm", passwordEncoder.encode("secret123"), "NoPerm");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, noPermUserId, noPermRoleId);
    }

    @AfterEach
    void cleanUp() {
        jdbcTemplate.update("DELETE FROM test_master WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM role_permission WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM user_roles WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM users WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM roles WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM department_master WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM branches WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM organizations WHERE id = ?", orgId);
    }

    private String loginAsActor() throws Exception {
        String body = "{\"organizationCode\":\"TESTIT\",\"branchCode\":\"BR1\","
                + "\"username\":\"test-actor\",\"password\":\"secret123\"}";
        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.token");
    }

    private String loginAsNoPermUser() throws Exception {
        String body = "{\"organizationCode\":\"TESTIT\",\"branchCode\":\"BR1\","
                + "\"username\":\"test-no-perm\",\"password\":\"secret123\"}";
        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.token");
    }

    private String testsUrl() {
        return "/api/organizations/" + orgId + "/branches/" + branchId + "/tests";
    }

    private String createTestReturningId(String token, String testCode) throws Exception {
        String body = "{\"departmentId\":\"" + departmentId + "\",\"testCode\":\"" + testCode
                + "\",\"testName\":\"" + testCode + " Test\"}";
        String response = mockMvc.perform(post(testsUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.id");
    }

    @Test
    void authorizedUserCanCreateTest() throws Exception {
        String token = loginAsActor();
        String body = "{\"departmentId\":\"" + departmentId + "\",\"testCode\":\"LFT001\","
                + "\"testName\":\"Liver Function Test\",\"sellingPrice\":600,\"costPrice\":350}";

        mockMvc.perform(post(testsUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.message").value("Test created successfully"))
                .andExpect(jsonPath("$.data.departmentId").value(departmentId.toString()))
                .andExpect(jsonPath("$.data.testCode").value("LFT001"))
                .andExpect(jsonPath("$.data.sellingPrice").value(600))
                .andExpect(jsonPath("$.data.isActive").value(true));
    }

    @Test
    void createMissingTestCodeReturns400() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(post(testsUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"departmentId\":\"" + departmentId + "\",\"testName\":\"Liver Function Test\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("testCode is required"));
    }

    @Test
    void createUnknownBranchReturns404() throws Exception {
        String token = loginAsActor();
        String body = "{\"departmentId\":\"" + departmentId + "\",\"testCode\":\"LFT002\","
                + "\"testName\":\"Liver Function Test 2\"}";

        mockMvc.perform(post("/api/organizations/" + orgId + "/branches/" + UUID.randomUUID() + "/tests")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Branch not found"));
    }

    @Test
    void createUnknownDepartmentReturns404() throws Exception {
        String token = loginAsActor();
        String body = "{\"departmentId\":\"" + UUID.randomUUID() + "\",\"testCode\":\"LFT003\","
                + "\"testName\":\"Liver Function Test 3\"}";

        mockMvc.perform(post(testsUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Department not found"));
    }

    @Test
    void createDuplicateTestCodeReturns409() throws Exception {
        String token = loginAsActor();
        createTestReturningId(token, "LFT004");
        String body = "{\"departmentId\":\"" + departmentId + "\",\"testCode\":\"LFT004\","
                + "\"testName\":\"A Different Name\"}";

        mockMvc.perform(post(testsUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("Duplicate test code"));
    }

    @Test
    void listTestsReturnsTestsInScope() throws Exception {
        String token = loginAsActor();
        createTestReturningId(token, "LST001");

        mockMvc.perform(get(testsUrl()).header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Tests fetched successfully"))
                .andExpect(jsonPath("$.data[?(@.testCode == 'LST001')].departmentId")
                        .value(departmentId.toString()))
                .andExpect(jsonPath("$.data[?(@.testCode == 'LST001')].isActive").value(true));
    }

    @Test
    void listTestsUnknownBranchReturns404() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(get("/api/organizations/" + orgId + "/branches/" + UUID.randomUUID() + "/tests")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Organization or branch not found"));
    }

    @Test
    void listTestsMalformedPathParameterReturns400() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(get("/api/organizations/not-a-uuid/branches/" + branchId + "/tests")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Invalid request"));
    }

    @Test
    void searchTestsMatchesCodeOrName() throws Exception {
        String token = loginAsActor();
        createTestReturningId(token, "SRC001");

        mockMvc.perform(get(testsUrl() + "/search?query=src001")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Tests searched successfully"))
                .andExpect(jsonPath("$.data[0].testCode").value("SRC001"))
                .andExpect(jsonPath("$.data[0].testName").value("SRC001 Test"));
    }

    @Test
    void searchTestsWithNoMatchesReturnsEmptyList() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(get(testsUrl() + "/search?query=nosuchtestanywhere")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data").isEmpty());
    }

    @Test
    void searchTestsMissingQueryReturns400() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(get(testsUrl() + "/search").header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Search query is required"));
    }

    @Test
    void searchTestsUnknownBranchReturns404() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(get("/api/organizations/" + orgId + "/branches/" + UUID.randomUUID() + "/tests/search?query=lft")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Organization or branch not found"));
    }

    @Test
    void viewTestReturns200() throws Exception {
        String token = loginAsActor();
        String testId = createTestReturningId(token, "LFT005");

        mockMvc.perform(get(testsUrl() + "/" + testId).header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.testCode").value("LFT005"));
    }

    @Test
    void viewUnknownTestReturns404() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(get(testsUrl() + "/" + UUID.randomUUID())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Test not found"));
    }

    @Test
    void viewInactiveTestIsStillReturned() throws Exception {
        String token = loginAsActor();
        String testId = createTestReturningId(token, "LFT006");
        mockMvc.perform(patch(testsUrl() + "/" + testId + "/status")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"isActive\":false}"))
                .andExpect(status().isOk());

        mockMvc.perform(get(testsUrl() + "/" + testId).header(HttpHeaders.AUTHORIZATION, "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.isActive").value(false));
    }

    @Test
    void updateTestReturns200() throws Exception {
        String token = loginAsActor();
        String testId = createTestReturningId(token, "LFT007");

        mockMvc.perform(put(testsUrl() + "/" + testId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"departmentId\":\"" + departmentId + "\",\"testCode\":\"LFT007\","
                                + "\"testName\":\"Liver Function Test Updated\",\"sellingPrice\":650}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.testName").value("Liver Function Test Updated"))
                .andExpect(jsonPath("$.data.sellingPrice").value(650));
    }

    @Test
    void updateUnknownTestReturns404() throws Exception {
        String token = loginAsActor();

        mockMvc.perform(put(testsUrl() + "/" + UUID.randomUUID())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"departmentId\":\"" + departmentId + "\",\"testCode\":\"LFT008\","
                                + "\"testName\":\"Liver Function Test\"}"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Test not found"));
    }

    @Test
    void updateDuplicateTestNameReturns409() throws Exception {
        String token = loginAsActor();
        createTestReturningId(token, "LFT009");
        String secondId = createTestReturningId(token, "LFT010");

        mockMvc.perform(put(testsUrl() + "/" + secondId)
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"departmentId\":\"" + departmentId + "\",\"testCode\":\"LFT010\","
                                + "\"testName\":\"LFT009 Test\"}"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("Duplicate test name"));
    }

    @Test
    void statusUpdateReturns200() throws Exception {
        String token = loginAsActor();
        String testId = createTestReturningId(token, "LFT011");

        mockMvc.perform(patch(testsUrl() + "/" + testId + "/status")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"isActive\":false}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Test status updated successfully"))
                .andExpect(jsonPath("$.data.isActive").value(false));
    }

    @Test
    void statusUpdateMissingIsActiveReturns400() throws Exception {
        String token = loginAsActor();
        String testId = createTestReturningId(token, "LFT012");

        mockMvc.perform(patch(testsUrl() + "/" + testId + "/status")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Invalid status value"));
    }

    @Test
    void nonPermittedCallerIsForbidden() throws Exception {
        String token = loginAsNoPermUser();

        mockMvc.perform(post(testsUrl())
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"departmentId\":\"" + departmentId + "\",\"testCode\":\"LFT013\","
                                + "\"testName\":\"Liver Function Test\"}"))
                .andExpect(status().isForbidden());
    }

    @Test
    void missingTokenIsUnauthorized() throws Exception {
        mockMvc.perform(get(testsUrl() + "/" + UUID.randomUUID())).andExpect(status().isUnauthorized());
    }
}
