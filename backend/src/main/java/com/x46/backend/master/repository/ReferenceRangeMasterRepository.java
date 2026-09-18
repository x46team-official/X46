package com.x46.backend.master.repository;

import com.x46.backend.master.entity.ReferenceRangeMaster;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Limit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ReferenceRangeMasterRepository extends JpaRepository<ReferenceRangeMaster, UUID> {

    // API-113's documented filter: exact gender/pregnancy/unit, age inside the band,
    // asOfDate inside the effective window (open-ended when effective_to is NULL), newest first.
    @Query("SELECT r FROM ReferenceRangeMaster r WHERE r.organizationId = :organizationId AND r.branchId = :branchId "
            + "AND r.parameterId = :parameterId AND r.gender = :gender AND r.ageUnit = :ageUnit "
            + "AND r.pregnancyFlag = :pregnancyFlag AND r.active = TRUE "
            + "AND r.ageMin <= :age AND r.ageMax >= :age "
            + "AND r.effectiveFrom <= :asOfDate AND (r.effectiveTo IS NULL OR r.effectiveTo >= :asOfDate) "
            + "ORDER BY r.effectiveFrom DESC")
    List<ReferenceRangeMaster> lookup(
            @Param("organizationId") UUID organizationId,
            @Param("branchId") UUID branchId,
            @Param("parameterId") UUID parameterId,
            @Param("gender") String gender,
            @Param("ageUnit") String ageUnit,
            @Param("pregnancyFlag") boolean pregnancyFlag,
            @Param("age") BigDecimal age,
            @Param("asOfDate") LocalDate asOfDate,
            Limit limit);
}
