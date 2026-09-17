package com.x46.backend.master.repository;

import com.x46.backend.master.entity.TestMaster;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TestMasterRepository extends JpaRepository<TestMaster, UUID> {

    boolean existsByOrganizationIdAndBranchIdAndTestCode(UUID organizationId, UUID branchId, String testCode);

    boolean existsByOrganizationIdAndBranchIdAndTestName(UUID organizationId, UUID branchId, String testName);

    boolean existsByOrganizationIdAndBranchIdAndTestCodeAndIdNot(
            UUID organizationId, UUID branchId, String testCode, UUID id);

    boolean existsByOrganizationIdAndBranchIdAndTestNameAndIdNot(
            UUID organizationId, UUID branchId, String testName, UUID id);

    Optional<TestMaster> findByIdAndOrganizationIdAndBranchId(UUID id, UUID organizationId, UUID branchId);
}
