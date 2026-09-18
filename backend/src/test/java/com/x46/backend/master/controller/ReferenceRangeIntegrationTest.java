package com.x46.backend.master.controller;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
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
 * Full-stack coverage for API-111 (Create Parameter), API-112 (Create Reference Range),
 * API-113 (Lookup Reference Range) and their documented failure scenarios API-114-119,
 * against the real dockerized Postgres (including the overlap trigger behind API-116).
 */
@SpringBootTest
@AutoConfigureMockMvc
class ReferenceRangeIntegrationTest {

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
                orgId, "RRIT", "Reference Range IT Org");
        jdbcTemplate.update(
                "INSERT INTO branches (id, organization_id, branch_code, branch_name) VALUES (?, ?, ?, ?)",
                branchId, orgId, "BR1", "Reference Range IT Branch");
        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                actorRoleId, orgId, branchId, "ACTOR", "Actor Role");
        jdbcTemplate.update(
                "INSERT INTO role_permission (organization_id, branch_id, role_id, module_name, "
                        + "can_create, can_view, can_update) VALUES (?, ?, ?, 'Reference Range Master', TRUE, TRUE, TRUE)",
                orgId, branchId, actorRoleId);
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                userId, orgId, branchId, "rr-actor", passwordEncoder.encode("secret123"), "Actor");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, userId, actorRoleId);

        jdbcTemplate.update(
                "INSERT INTO roles (id, organization_id, branch_id, role_code, role_name) VALUES (?, ?, ?, ?, ?)",
                noPermRoleId, orgId, branchId, "NOPERM", "No Permission Role");
        jdbcTemplate.update(
                "INSERT INTO users (id, organization_id, branch_id, username, password_hash, first_name, is_active) "
                        + "VALUES (?, ?, ?, ?, ?, ?, TRUE)",
                noPermUserId, orgId, branchId, "rr-no-perm", passwordEncoder.encode("secret123"), "NoPerm");
        jdbcTemplate.update(
                "INSERT INTO user_roles (organization_id, branch_id, user_id, role_id) VALUES (?, ?, ?, ?)",
                orgId, branchId, noPermUserId, noPermRoleId);
    }

    @AfterEach
    void cleanUp() {
        jdbcTemplate.update("DELETE FROM reference_range_master WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM parameter_master WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM role_permission WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM user_roles WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM users WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM roles WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM branches WHERE organization_id = ?", orgId);
        jdbcTemplate.update("DELETE FROM organizations WHERE id = ?", orgId);
    }

    private String login(String username) throws Exception {
        String body = "{\"organizationCode\":\"RRIT\",\"branchCode\":\"BR1\","
                + "\"username\":\"" + username + "\",\"password\":\"secret123\"}";
        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.token");
    }

    private String parameterBody(String code, String name) {
        return "{\"organizationId\":\"" + orgId + "\",\"branchId\":\"" + branchId + "\",\"parameterCode\":\""
                + code + "\",\"parameterName\":\"" + name + "\",\"unit\":\"g/dL\"}";
    }

    private String createParameterReturningId(String token) throws Exception {
        String response = mockMvc.perform(post("/api/parameters")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(parameterBody("HGB", "Hemoglobin")))
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(response, "$.data.id");
    }

    /** MALE 18-120 YEARS band, 13.0-17.0, from the given date with no end. */
    private String rangeBody(String parameterId, String effectiveFrom) {
        return "{\"organizationId\":\"" + orgId + "\",\"branchId\":\"" + branchId + "\",\"parameterId\":\""
                + parameterId + "\",\"gender\":\"MALE\",\"ageMin\":18,\"ageMax\":120,\"ageUnit\":\"YEARS\","
                + "\"pregnancyFlag\":false,\"referenceMin\":13.0,\"referenceMax\":17.0,"
                + "\"referenceRange\":\"13.0 - 17.0\",\"criticalLow\":7.0,\"criticalHigh\":20.0,"
                + "\"effectiveFrom\":\"" + effectiveFrom + "\"}";
    }

    private void createRange(String token, String body) throws Exception {
        mockMvc.perform(post("/api/reference-ranges")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                .contentType(MediaType.APPLICATION_JSON)
                .content(body));
    }

    // --- create parameter (API-111 / API-115) ---

    @Test
    void authorizedUserCanCreateParameter() throws Exception {
        String token = login("rr-actor");

        mockMvc.perform(post("/api/parameters")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(parameterBody("TBIL", "Total Bilirubin")))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.message").value("Parameter created successfully"))
                .andExpect(jsonPath("$.data.parameterCode").value("TBIL"))
                .andExpect(jsonPath("$.data.parameterName").value("Total Bilirubin"))
                .andExpect(jsonPath("$.data.unit").value("g/dL"));
    }

    @Test
    void createParameterDuplicateCodeReturns409() throws Exception {
        String token = login("rr-actor");
        createParameterReturningId(token);

        mockMvc.perform(post("/api/parameters")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(parameterBody("HGB", "Another Name")))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("Duplicate parameter code"));
    }

    @Test
    void createParameterUnknownBranchReturns404() throws Exception {
        String token = login("rr-actor");
        String body = "{\"organizationId\":\"" + orgId + "\",\"branchId\":\"" + UUID.randomUUID()
                + "\",\"parameterCode\":\"TBIL\",\"parameterName\":\"Total Bilirubin\"}";

        mockMvc.perform(post("/api/parameters")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Organization or branch not found"));
    }

    // --- create reference range (API-112 / API-114, 116-119) ---

    @Test
    void authorizedUserCanCreateReferenceRange() throws Exception {
        String token = login("rr-actor");
        String parameterId = createParameterReturningId(token);

        mockMvc.perform(post("/api/reference-ranges")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(rangeBody(parameterId, "2020-01-01")))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.message").value("Reference range created successfully"))
                .andExpect(jsonPath("$.data.parameterId").value(parameterId))
                .andExpect(jsonPath("$.data.gender").value("MALE"))
                .andExpect(jsonPath("$.data.ageMin").value(18))
                .andExpect(jsonPath("$.data.ageUnit").value("YEARS"))
                .andExpect(jsonPath("$.data.pregnancyFlag").value(false))
                .andExpect(jsonPath("$.data.referenceMax").value(17.0))
                .andExpect(jsonPath("$.data.effectiveFrom").value("2020-01-01"));
    }

    @Test
    void overlappingBandIsRejectedByTriggerWith409() throws Exception {
        String token = login("rr-actor");
        String parameterId = createParameterReturningId(token);
        createRange(token, rangeBody(parameterId, "2020-01-01"));

        mockMvc.perform(post("/api/reference-ranges")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(rangeBody(parameterId, "2021-06-01")))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error").value("Overlapping demographic band"));
    }

    @Test
    void unknownParameterReturns404() throws Exception {
        String token = login("rr-actor");

        mockMvc.perform(post("/api/reference-ranges")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(rangeBody("00000000-0000-0000-0000-000000000000", "2020-01-01")))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Parameter not found"));
    }

    @Test
    void invalidAgeRangeReturns400() throws Exception {
        String token = login("rr-actor");
        String parameterId = createParameterReturningId(token);
        String body = "{\"organizationId\":\"" + orgId + "\",\"branchId\":\"" + branchId + "\",\"parameterId\":\""
                + parameterId + "\",\"ageMin\":50,\"ageMax\":10}";

        mockMvc.perform(post("/api/reference-ranges")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Invalid age range"));
    }

    @Test
    void invalidEffectiveDateRangeReturns400() throws Exception {
        String token = login("rr-actor");
        String parameterId = createParameterReturningId(token);
        String body = "{\"organizationId\":\"" + orgId + "\",\"branchId\":\"" + branchId + "\",\"parameterId\":\""
                + parameterId + "\",\"effectiveFrom\":\"2024-01-01\",\"effectiveTo\":\"2023-01-01\"}";

        mockMvc.perform(post("/api/reference-ranges")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Invalid effective date range"));
    }

    @Test
    void invalidReferenceBoundsReturns400() throws Exception {
        String token = login("rr-actor");
        String parameterId = createParameterReturningId(token);
        String body = "{\"organizationId\":\"" + orgId + "\",\"branchId\":\"" + branchId + "\",\"parameterId\":\""
                + parameterId + "\",\"referenceMin\":17.0,\"referenceMax\":13.0}";

        mockMvc.perform(post("/api/reference-ranges")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Invalid reference bounds"));
    }

    // --- lookup (API-113) ---

    @Test
    void lookupReturnsMatchingBand() throws Exception {
        String token = login("rr-actor");
        String parameterId = createParameterReturningId(token);
        createRange(token, rangeBody(parameterId, "2020-01-01"));

        mockMvc.perform(get("/api/reference-ranges/lookup")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .param("parameterId", parameterId)
                        .param("gender", "MALE")
                        .param("age", "30")
                        .param("ageUnit", "YEARS")
                        .param("asOfDate", "2024-06-01"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.referenceMin").value(13.0))
                .andExpect(jsonPath("$.data.referenceMax").value(17.0))
                .andExpect(jsonPath("$.data.referenceRange").value("13.0 - 17.0"))
                .andExpect(jsonPath("$.data.criticalLow").value(7.0))
                .andExpect(jsonPath("$.data.criticalHigh").value(20.0))
                .andExpect(jsonPath("$.data.effectiveFrom").value("2020-01-01"))
                .andExpect(jsonPath("$.data.effectiveTo").isEmpty());
    }

    @Test
    void lookupOutsideAnyBandReturns404() throws Exception {
        String token = login("rr-actor");
        String parameterId = createParameterReturningId(token);
        createRange(token, rangeBody(parameterId, "2020-01-01"));

        mockMvc.perform(get("/api/reference-ranges/lookup")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .param("parameterId", parameterId)
                        .param("gender", "MALE")
                        .param("age", "10")
                        .param("ageUnit", "YEARS"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("No matching reference range found"));
    }

    @Test
    void lookupMissingAgeReturns400() throws Exception {
        String token = login("rr-actor");

        mockMvc.perform(get("/api/reference-ranges/lookup")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .param("parameterId", UUID.randomUUID().toString())
                        .param("gender", "MALE")
                        .param("ageUnit", "YEARS"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("age is required"));
    }

    // --- security ---

    @Test
    void nonPermittedCallerIsForbidden() throws Exception {
        String token = login("rr-no-perm");

        mockMvc.perform(post("/api/parameters")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(parameterBody("TBIL", "Total Bilirubin")))
                .andExpect(status().isForbidden());
    }

    @Test
    void missingTokenIsUnauthorized() throws Exception {
        mockMvc.perform(get("/api/reference-ranges/lookup")).andExpect(status().isUnauthorized());
    }
}
