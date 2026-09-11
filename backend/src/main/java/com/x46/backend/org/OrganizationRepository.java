package com.x46.backend.org;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

interface OrganizationRepository extends JpaRepository<Organization, UUID> {

    boolean existsByOrganizationCode(String organizationCode);
}
