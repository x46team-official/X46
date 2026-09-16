package com.x46.backend.identity.repository;

import com.x46.backend.identity.entity.UserRole;
import com.x46.backend.identity.entity.UserRoleId;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRoleRepository extends JpaRepository<UserRole, UserRoleId> {

    boolean existsByUserIdAndRoleId(UUID userId, UUID roleId);
}
