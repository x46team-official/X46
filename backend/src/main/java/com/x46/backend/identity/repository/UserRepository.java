package com.x46.backend.identity.repository;

import com.x46.backend.identity.entity.User;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UserRepository extends JpaRepository<User, UUID> {

    boolean existsByOrganizationIdAndBranchIdAndUsername(UUID organizationId, UUID branchId, String username);

    boolean existsByUsername(String username);

    Optional<User> findByIdAndOrganizationIdAndBranchId(UUID id, UUID organizationId, UUID branchId);

    List<User> findByOrganizationIdAndBranchId(UUID organizationId, UUID branchId);

    List<User> findByOrganizationIdAndBranchIdAndActive(UUID organizationId, UUID branchId, boolean active);

    @Query("SELECT u FROM User u WHERE u.organizationId = :organizationId AND u.branchId = :branchId "
            + "AND (LOWER(u.username) LIKE LOWER(CONCAT('%', :search, '%')) "
            + "OR LOWER(u.firstName) LIKE LOWER(CONCAT('%', :search, '%')) "
            + "OR LOWER(u.lastName) LIKE LOWER(CONCAT('%', :search, '%')))")
    List<User> search(
            @Param("organizationId") UUID organizationId,
            @Param("branchId") UUID branchId,
            @Param("search") String search);

    @Query("SELECT u FROM User u WHERE u.organizationId = :organizationId AND u.branchId = :branchId "
            + "AND u.active = :active "
            + "AND (LOWER(u.username) LIKE LOWER(CONCAT('%', :search, '%')) "
            + "OR LOWER(u.firstName) LIKE LOWER(CONCAT('%', :search, '%')) "
            + "OR LOWER(u.lastName) LIKE LOWER(CONCAT('%', :search, '%')))")
    List<User> searchByActive(
            @Param("organizationId") UUID organizationId,
            @Param("branchId") UUID branchId,
            @Param("active") boolean active,
            @Param("search") String search);
}
