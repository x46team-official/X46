package com.x46.backend.common;

import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * The org/branch existence check nearly every API contract's validation[]
 * repeats. Queries organizations/branches directly (not JPA entities) since
 * those tables' real entities belong to Chunk 1.1/1.2 (org.Organization,
 * org.Branch), not this chunk.
 */
@Component
public class ScopeGuard {

    private static final String NOT_FOUND_MESSAGE = "Organization or branch not found";

    private final JdbcTemplate jdbcTemplate;

    public ScopeGuard(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void requireOrg(UUID organizationId) {
        Boolean organizationExists = jdbcTemplate.queryForObject(
                "SELECT EXISTS(SELECT 1 FROM organizations WHERE id = ?)", Boolean.class, organizationId);
        if (!Boolean.TRUE.equals(organizationExists)) {
            throw new NotFoundException("Organization not found");
        }
    }

    public void requireOrgBranch(UUID organizationId, UUID branchId) {
        Boolean organizationExists = jdbcTemplate.queryForObject(
                "SELECT EXISTS(SELECT 1 FROM organizations WHERE id = ?)", Boolean.class, organizationId);
        if (!Boolean.TRUE.equals(organizationExists)) {
            throw new NotFoundException(NOT_FOUND_MESSAGE);
        }

        Boolean branchExists = jdbcTemplate.queryForObject(
                "SELECT EXISTS(SELECT 1 FROM branches WHERE id = ? AND organization_id = ?)",
                Boolean.class, branchId, organizationId);
        if (!Boolean.TRUE.equals(branchExists)) {
            throw new NotFoundException(NOT_FOUND_MESSAGE);
        }
    }
}
