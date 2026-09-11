package com.x46.backend.common;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.UUID;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;

@SpringBootTest
class ScopeGuardIntegrationTest {

    @Autowired
    private ScopeGuard scopeGuard;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private final UUID orgId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();

    @BeforeEach
    void seed() {
        jdbcTemplate.update(
                "INSERT INTO organizations (id, organization_code, organization_name) VALUES (?, ?, ?)",
                orgId, "SCOPEIT", "Scope Guard IT Org");
        jdbcTemplate.update(
                "INSERT INTO branches (id, organization_id, branch_code, branch_name) VALUES (?, ?, ?, ?)",
                branchId, orgId, "BR1", "Scope Guard IT Branch");
    }

    @AfterEach
    void cleanUp() {
        jdbcTemplate.update("DELETE FROM branches WHERE id = ?", branchId);
        jdbcTemplate.update("DELETE FROM organizations WHERE id = ?", orgId);
    }

    @Test
    void validOrganizationPasses() {
        assertThatCode(() -> scopeGuard.requireOrg(orgId)).doesNotThrowAnyException();
    }

    @Test
    void unknownOrganizationAloneIsRejected() {
        assertThatThrownBy(() -> scopeGuard.requireOrg(UUID.randomUUID()))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization not found");
    }

    @Test
    void validOrgAndBranchPasses() {
        assertThatCode(() -> scopeGuard.requireOrgBranch(orgId, branchId)).doesNotThrowAnyException();
    }

    @Test
    void unknownOrganizationIsRejected() {
        assertThatThrownBy(() -> scopeGuard.requireOrgBranch(UUID.randomUUID(), branchId))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization or branch not found");
    }

    @Test
    void unknownBranchUnderAValidOrgIsRejected() {
        assertThatThrownBy(() -> scopeGuard.requireOrgBranch(orgId, UUID.randomUUID()))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization or branch not found");
    }

    @Test
    void branchBelongingToAnotherOrganizationIsRejected() {
        UUID otherOrgId = UUID.randomUUID();
        jdbcTemplate.update(
                "INSERT INTO organizations (id, organization_code, organization_name) VALUES (?, ?, ?)",
                otherOrgId, "SCOPEIT2", "Other Org");
        try {
            assertThatThrownBy(() -> scopeGuard.requireOrgBranch(otherOrgId, branchId))
                    .isInstanceOf(NotFoundException.class)
                    .hasMessage("Organization or branch not found");
        } finally {
            jdbcTemplate.update("DELETE FROM organizations WHERE id = ?", otherOrgId);
        }
    }
}
