package com.x46.backend.security;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

/**
 * Narrow, read-only lookups login needs against tables whose full entities
 * belong to later M1 chunks (org.Organization, org.Branch, identity.User,
 * identity.Role) — not duplicated here as JPA entities to avoid a second,
 * throwaway model of the same tables.
 */
@Repository
class AuthLookupRepository {

    private final JdbcTemplate jdbcTemplate;

    AuthLookupRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    Optional<UUID> findOrganizationId(String organizationCode) {
        return jdbcTemplate.query(
                        "SELECT id FROM organizations WHERE organization_code = ?",
                        (rs, rowNum) -> (UUID) rs.getObject("id"),
                        organizationCode)
                .stream()
                .findFirst();
    }

    Optional<UUID> findBranchId(UUID organizationId, String branchCode) {
        return jdbcTemplate.query(
                        "SELECT id FROM branches WHERE organization_id = ? AND branch_code = ?",
                        (rs, rowNum) -> (UUID) rs.getObject("id"),
                        organizationId, branchCode)
                .stream()
                .findFirst();
    }

    Optional<AuthUserRow> findUser(UUID organizationId, UUID branchId, String username) {
        return jdbcTemplate.query(
                        "SELECT id, password_hash, is_active FROM users "
                                + "WHERE organization_id = ? AND branch_id = ? AND username = ?",
                        (rs, rowNum) -> new AuthUserRow(
                                (UUID) rs.getObject("id"),
                                rs.getString("password_hash"),
                                rs.getBoolean("is_active")),
                        organizationId, branchId, username)
                .stream()
                .findFirst();
    }

    List<UUID> findRoleIds(UUID userId) {
        return jdbcTemplate.query(
                "SELECT role_id FROM user_roles WHERE user_id = ?",
                (rs, rowNum) -> (UUID) rs.getObject("role_id"),
                userId);
    }

    record AuthUserRow(UUID id, String passwordHash, boolean active) {
    }
}
