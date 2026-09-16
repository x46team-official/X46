package com.x46.backend.org.service;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.ValidationException;
import com.x46.backend.org.dto.CreateOrganizationRequest;
import com.x46.backend.org.dto.OrganizationResponse;
import com.x46.backend.org.dto.OrganizationSummaryResponse;
import com.x46.backend.org.entity.Organization;
import com.x46.backend.org.repository.OrganizationRepository;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class OrganizationService {

    private final OrganizationRepository organizationRepository;
    private final JdbcTemplate jdbcTemplate;

    OrganizationService(OrganizationRepository organizationRepository, JdbcTemplate jdbcTemplate) {
        this.organizationRepository = organizationRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    public OrganizationResponse create(CreateOrganizationRequest request) {
        if (isBlank(request.organizationName())) {
            throw new ValidationException("organizationName is required");
        }
        if (isBlank(request.organizationCode())) {
            throw new ValidationException("organizationCode is required");
        }
        if (organizationRepository.existsByOrganizationCode(request.organizationCode())) {
            throw new ConflictException("Duplicate organization code");
        }

        OffsetDateTime now = OffsetDateTime.now();
        Organization organization = new Organization();
        organization.setOrganizationCode(request.organizationCode());
        organization.setOrganizationName(request.organizationName());
        organization.setActive(request.isActive() == null || request.isActive());
        organization.setCreatedAt(now);
        organization.setUpdatedAt(now);

        Organization saved = organizationRepository.save(organization);
        return new OrganizationResponse(
                saved.getId(), saved.getOrganizationCode(), saved.getOrganizationName(), saved.isActive());
    }

    public List<OrganizationSummaryResponse> listWithCounts() {
        return jdbcTemplate.query(
                "SELECT o.id, o.organization_code, o.organization_name, o.is_active, "
                        + "COUNT(DISTINCT b.id) AS branch_count, COUNT(DISTINCT u.id) AS user_count "
                        + "FROM organizations o "
                        + "LEFT JOIN branches b ON b.organization_id = o.id "
                        + "LEFT JOIN users u ON u.organization_id = o.id "
                        + "GROUP BY o.id, o.organization_code, o.organization_name, o.is_active "
                        + "ORDER BY o.organization_name",
                (rs, rowNum) -> new OrganizationSummaryResponse(
                        (UUID) rs.getObject("id"),
                        rs.getString("organization_code"),
                        rs.getString("organization_name"),
                        rs.getBoolean("is_active"),
                        rs.getLong("branch_count"),
                        rs.getLong("user_count")));
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
