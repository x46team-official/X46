package com.x46.backend.master.repository;

import com.x46.backend.master.entity.TestMaster;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TestMasterRepository extends JpaRepository<TestMaster, UUID> {

    boolean existsByOrganizationIdAndBranchIdAndTestCode(UUID organizationId, UUID branchId, String testCode);

    boolean existsByOrganizationIdAndBranchIdAndTestName(UUID organizationId, UUID branchId, String testName);

    boolean existsByOrganizationIdAndBranchIdAndTestCodeAndIdNot(
            UUID organizationId, UUID branchId, String testCode, UUID id);

    boolean existsByOrganizationIdAndBranchIdAndTestNameAndIdNot(
            UUID organizationId, UUID branchId, String testName, UUID id);

    Optional<TestMaster> findByIdAndOrganizationIdAndBranchId(UUID id, UUID organizationId, UUID branchId);

    List<TestMaster> findByOrganizationIdAndBranchId(UUID organizationId, UUID branchId);

    @Query("SELECT t FROM TestMaster t WHERE t.organizationId = :organizationId AND t.branchId = :branchId "
            + "AND (LOWER(t.testCode) LIKE LOWER(CONCAT('%', :query, '%')) "
            + "OR LOWER(t.testName) LIKE LOWER(CONCAT('%', :query, '%')))")
    List<TestMaster> search(
            @Param("organizationId") UUID organizationId,
            @Param("branchId") UUID branchId,
            @Param("query") String query);
}
