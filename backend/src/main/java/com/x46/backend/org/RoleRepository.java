package com.x46.backend.org;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

interface RoleRepository extends JpaRepository<Role, UUID> {

    boolean existsByOrganizationIdAndBranchIdAndRoleCode(UUID organizationId, UUID branchId, String roleCode);

    boolean existsByOrganizationIdAndBranchIdAndRoleCodeAndIdNot(
            UUID organizationId, UUID branchId, String roleCode, UUID id);

    Optional<Role> findByIdAndOrganizationIdAndBranchId(UUID id, UUID organizationId, UUID branchId);

    List<Role> findByOrganizationIdAndBranchId(UUID organizationId, UUID branchId);

    @Query("SELECT r FROM Role r WHERE r.organizationId = :organizationId AND r.branchId = :branchId "
            + "AND (LOWER(r.roleCode) LIKE LOWER(CONCAT('%', :search, '%')) "
            + "OR LOWER(r.roleName) LIKE LOWER(CONCAT('%', :search, '%')))")
    List<Role> search(
            @Param("organizationId") UUID organizationId,
            @Param("branchId") UUID branchId,
            @Param("search") String search);
}
