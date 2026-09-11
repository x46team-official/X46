package com.x46.backend.org;

import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

interface BranchRepository extends JpaRepository<Branch, UUID> {

    boolean existsByOrganizationIdAndBranchCode(UUID organizationId, String branchCode);
}
