package com.x46.backend.master.repository;

import com.x46.backend.master.entity.ParameterMaster;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ParameterMasterRepository extends JpaRepository<ParameterMaster, UUID> {

    boolean existsByOrganizationIdAndBranchIdAndParameterCode(UUID organizationId, UUID branchId, String parameterCode);

    boolean existsByOrganizationIdAndBranchIdAndParameterName(UUID organizationId, UUID branchId, String parameterName);

    boolean existsByIdAndOrganizationIdAndBranchId(UUID id, UUID organizationId, UUID branchId);
}
