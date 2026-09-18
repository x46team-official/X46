package com.x46.backend.master.service;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.NotFoundException;
import com.x46.backend.common.ScopeGuard;
import com.x46.backend.common.ValidationException;
import com.x46.backend.master.dto.CreateParameterRequest;
import com.x46.backend.master.dto.CreateReferenceRangeRequest;
import com.x46.backend.master.dto.ParameterResponse;
import com.x46.backend.master.dto.ReferenceRangeLookupQuery;
import com.x46.backend.master.dto.ReferenceRangeLookupResponse;
import com.x46.backend.master.dto.ReferenceRangeResponse;
import com.x46.backend.master.entity.ParameterMaster;
import com.x46.backend.master.entity.ReferenceRangeMaster;
import com.x46.backend.master.repository.ParameterMasterRepository;
import com.x46.backend.master.repository.ReferenceRangeMasterRepository;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.Set;
import java.util.UUID;
import org.springframework.core.NestedExceptionUtils;
import org.springframework.dao.DataAccessException;
import org.springframework.data.domain.Limit;
import org.springframework.stereotype.Service;

@Service
public class ReferenceRangeService {

    private static final Set<String> GENDERS = Set.of("MALE", "FEMALE", "ANY");
    private static final Set<String> AGE_UNITS = Set.of("DAYS", "MONTHS", "YEARS");

    private final ParameterMasterRepository parameterRepository;
    private final ReferenceRangeMasterRepository referenceRangeRepository;
    private final ScopeGuard scopeGuard;

    ReferenceRangeService(
            ParameterMasterRepository parameterRepository,
            ReferenceRangeMasterRepository referenceRangeRepository,
            ScopeGuard scopeGuard) {
        this.parameterRepository = parameterRepository;
        this.referenceRangeRepository = referenceRangeRepository;
        this.scopeGuard = scopeGuard;
    }

    public ParameterResponse createParameter(CreateParameterRequest request) {
        require(request.organizationId(), "organizationId");
        require(request.branchId(), "branchId");
        require(request.parameterCode(), "parameterCode");
        require(request.parameterName(), "parameterName");
        UUID organizationId = request.organizationId();
        UUID branchId = request.branchId();
        scopeGuard.requireOrgBranch(organizationId, branchId);
        if (parameterRepository.existsByOrganizationIdAndBranchIdAndParameterCode(
                organizationId, branchId, request.parameterCode())) {
            throw new ConflictException("Duplicate parameter code");
        }
        if (parameterRepository.existsByOrganizationIdAndBranchIdAndParameterName(
                organizationId, branchId, request.parameterName())) {
            throw new ConflictException("Duplicate parameter name");
        }

        ParameterMaster parameter = new ParameterMaster();
        parameter.setOrganizationId(organizationId);
        parameter.setBranchId(branchId);
        parameter.setParameterCode(request.parameterCode());
        parameter.setParameterName(request.parameterName());
        parameter.setUnit(request.unit());
        parameter.setDefaultReferenceRange(request.defaultReferenceRange());
        parameter.setActive(true);
        OffsetDateTime now = OffsetDateTime.now();
        parameter.setCreatedAt(now);
        parameter.setUpdatedAt(now);

        ParameterMaster saved = parameterRepository.save(parameter);
        return new ParameterResponse(
                saved.getId(),
                saved.getParameterCode(),
                saved.getParameterName(),
                saved.getUnit(),
                saved.getDefaultReferenceRange());
    }

    public ReferenceRangeResponse createReferenceRange(CreateReferenceRangeRequest request) {
        require(request.organizationId(), "organizationId");
        require(request.branchId(), "branchId");
        require(request.parameterId(), "parameterId");

        // Defaults are the column defaults API-112 documents.
        String gender = request.gender() == null ? "ANY" : request.gender();
        BigDecimal ageMin = request.ageMin() == null ? BigDecimal.ZERO : request.ageMin();
        BigDecimal ageMax = request.ageMax() == null ? BigDecimal.valueOf(150) : request.ageMax();
        String ageUnit = request.ageUnit() == null ? "YEARS" : request.ageUnit();
        LocalDate effectiveFrom = request.effectiveFrom() == null ? LocalDate.now() : request.effectiveFrom();

        if (!GENDERS.contains(gender)) {
            throw new ValidationException("Invalid gender");
        }
        if (!AGE_UNITS.contains(ageUnit)) {
            throw new ValidationException("Invalid age unit");
        }
        if (ageMax.compareTo(ageMin) < 0) {
            throw new ValidationException("Invalid age range");
        }
        if (request.effectiveTo() != null && request.effectiveTo().isBefore(effectiveFrom)) {
            throw new ValidationException("Invalid effective date range");
        }
        if (request.referenceMin() != null && request.referenceMax() != null
                && request.referenceMax().compareTo(request.referenceMin()) < 0) {
            throw new ValidationException("Invalid reference bounds");
        }

        UUID organizationId = request.organizationId();
        UUID branchId = request.branchId();
        scopeGuard.requireOrgBranch(organizationId, branchId);
        if (!parameterRepository.existsByIdAndOrganizationIdAndBranchId(request.parameterId(), organizationId, branchId)) {
            throw new NotFoundException("Parameter not found");
        }

        ReferenceRangeMaster range = new ReferenceRangeMaster();
        range.setOrganizationId(organizationId);
        range.setBranchId(branchId);
        range.setParameterId(request.parameterId());
        range.setGender(gender);
        range.setAgeMin(ageMin);
        range.setAgeMax(ageMax);
        range.setAgeUnit(ageUnit);
        range.setPregnancyFlag(Boolean.TRUE.equals(request.pregnancyFlag()));
        range.setReferenceMin(request.referenceMin());
        range.setReferenceMax(request.referenceMax());
        range.setReferenceRange(request.referenceRange());
        range.setCriticalLow(request.criticalLow());
        range.setCriticalHigh(request.criticalHigh());
        range.setEffectiveFrom(effectiveFrom);
        range.setEffectiveTo(request.effectiveTo());
        range.setActive(true);
        OffsetDateTime now = OffsetDateTime.now();
        range.setCreatedAt(now);
        range.setUpdatedAt(now);

        ReferenceRangeMaster saved;
        try {
            saved = referenceRangeRepository.saveAndFlush(range);
        } catch (DataAccessException ex) {
            // Overlap is enforced by the DB trigger trg_prevent_reference_range_overlap (API-116),
            // so the DB stays the single source of truth instead of a Java copy of its query.
            String cause = NestedExceptionUtils.getMostSpecificCause(ex).getMessage();
            if (cause != null && cause.contains("overlapping demographic band")) {
                throw new ConflictException("Overlapping demographic band");
            }
            throw ex;
        }
        return new ReferenceRangeResponse(
                saved.getId(),
                saved.getParameterId(),
                saved.getGender(),
                saved.getAgeMin(),
                saved.getAgeMax(),
                saved.getAgeUnit(),
                saved.isPregnancyFlag(),
                saved.getReferenceMin(),
                saved.getReferenceMax(),
                saved.getEffectiveFrom());
    }

    public ReferenceRangeLookupResponse lookup(UUID organizationId, UUID branchId, ReferenceRangeLookupQuery query) {
        require(query.parameterId(), "parameterId");
        require(query.gender(), "gender");
        require(query.age(), "age");
        require(query.ageUnit(), "ageUnit");
        LocalDate asOfDate = query.asOfDate() == null ? LocalDate.now() : query.asOfDate();

        return referenceRangeRepository
                .lookup(
                        organizationId,
                        branchId,
                        query.parameterId(),
                        query.gender(),
                        query.ageUnit(),
                        Boolean.TRUE.equals(query.pregnancyFlag()),
                        query.age(),
                        asOfDate,
                        Limit.of(1))
                .stream()
                .findFirst()
                .map(r -> new ReferenceRangeLookupResponse(
                        r.getReferenceMin(),
                        r.getReferenceMax(),
                        r.getReferenceRange(),
                        r.getCriticalLow(),
                        r.getCriticalHigh(),
                        r.getEffectiveFrom(),
                        r.getEffectiveTo()))
                .orElseThrow(() -> new NotFoundException("No matching reference range found"));
    }

    private static void require(Object value, String field) {
        if (value == null || (value instanceof String s && s.isBlank())) {
            throw new ValidationException(field + " is required");
        }
    }
}
