package com.x46.backend.master.repository;

import com.x46.backend.master.entity.DepartmentMaster;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DepartmentMasterRepository extends JpaRepository<DepartmentMaster, UUID> {

    boolean existsByOrganizationIdAndBranchIdAndDepartmentCode(UUID organizationId, UUID branchId, String departmentCode);

    boolean existsByOrganizationIdAndBranchIdAndDepartmentName(UUID organizationId, UUID branchId, String departmentName);

    boolean existsByOrganizationIdAndBranchIdAndDepartmentCodeAndIdNot(
            UUID organizationId, UUID branchId, String departmentCode, UUID id);

    boolean existsByOrganizationIdAndBranchIdAndDepartmentNameAndIdNot(
            UUID organizationId, UUID branchId, String departmentName, UUID id);

    Optional<DepartmentMaster> findByIdAndOrganizationIdAndBranchId(UUID id, UUID organizationId, UUID branchId);
}
