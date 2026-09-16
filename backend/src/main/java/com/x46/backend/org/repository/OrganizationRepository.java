package com.x46.backend.org.repository;

import com.x46.backend.org.entity.Organization;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrganizationRepository extends JpaRepository<Organization, UUID> {

    boolean existsByOrganizationCode(String organizationCode);
}
