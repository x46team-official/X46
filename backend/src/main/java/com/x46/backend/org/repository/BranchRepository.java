package com.x46.backend.org.repository;

import com.x46.backend.org.entity.Branch;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BranchRepository extends JpaRepository<Branch, UUID> {

    boolean existsByOrganizationIdAndBranchCode(UUID organizationId, String branchCode);
}
