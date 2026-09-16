package com.x46.backend.org.service;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.ValidationException;
import com.x46.backend.org.dto.CreateOrganizationRequest;
import com.x46.backend.org.dto.OrganizationResponse;
import com.x46.backend.org.entity.Organization;
import com.x46.backend.org.repository.OrganizationRepository;
import java.time.OffsetDateTime;
import org.springframework.stereotype.Service;

@Service
public class OrganizationService {

    private final OrganizationRepository organizationRepository;

    OrganizationService(OrganizationRepository organizationRepository) {
        this.organizationRepository = organizationRepository;
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

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
