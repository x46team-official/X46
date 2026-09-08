package com.x46.backend.security;

import java.util.Collection;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

interface RolePermissionRepository extends JpaRepository<RolePermission, UUID> {

    List<RolePermission> findByOrganizationIdAndBranchIdAndRoleIdInAndModuleName(
            UUID organizationId, UUID branchId, Collection<UUID> roleIds, String moduleName);
}
