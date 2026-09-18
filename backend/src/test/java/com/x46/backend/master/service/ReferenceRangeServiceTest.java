package com.x46.backend.master.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

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
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Limit;

@ExtendWith(MockitoExtension.class)
class ReferenceRangeServiceTest {

    @Mock
    private ParameterMasterRepository parameterRepository;

    @Mock
    private ReferenceRangeMasterRepository referenceRangeRepository;

    @Mock
    private ScopeGuard scopeGuard;

    private ReferenceRangeService service;

    private final UUID organizationId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();
    private final UUID parameterId = UUID.randomUUID();
    private final UUID rangeId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        service = new ReferenceRangeService(parameterRepository, referenceRangeRepository, scopeGuard);
    }

    private CreateParameterRequest parameterRequest() {
        return new CreateParameterRequest(organizationId, branchId, "TBIL", "Total Bilirubin", "mg/dL", "0.3 - 1.2");
    }

    private CreateReferenceRangeRequest rangeRequest(
            BigDecimal ageMin, BigDecimal ageMax, BigDecimal refMin, BigDecimal refMax, LocalDate from, LocalDate to) {
        return new CreateReferenceRangeRequest(
                organizationId, branchId, parameterId, "MALE", ageMin, ageMax, "YEARS", false,
                refMin, refMax, null, null, null, from, to);
    }

    private CreateReferenceRangeRequest validRangeRequest() {
        return rangeRequest(BigDecimal.valueOf(18), BigDecimal.valueOf(120), new BigDecimal("13.0"),
                new BigDecimal("17.0"), LocalDate.of(2020, 1, 1), null);
    }

    private void stubParameterExists(boolean exists) {
        when(parameterRepository.existsByIdAndOrganizationIdAndBranchId(parameterId, organizationId, branchId))
                .thenReturn(exists);
    }

    // --- create parameter (API-111 / API-115) ---

    @Test
    void createParameterMissingCodeIsRejected() {
        var request = new CreateParameterRequest(organizationId, branchId, " ", "Total Bilirubin", null, null);

        assertThatThrownBy(() -> service.createParameter(request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("parameterCode is required");
        verifyNoInteractions(scopeGuard, parameterRepository);
    }

    @Test
    void createParameterUnknownOrgOrBranchIsRejected() {
        doThrow(new NotFoundException("Organization or branch not found"))
                .when(scopeGuard).requireOrgBranch(organizationId, branchId);

        assertThatThrownBy(() -> service.createParameter(parameterRequest()))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization or branch not found");
        verifyNoInteractions(parameterRepository);
    }

    @Test
    void createParameterDuplicateCodeIsRejected() {
        when(parameterRepository.existsByOrganizationIdAndBranchIdAndParameterCode(organizationId, branchId, "TBIL"))
                .thenReturn(true);

        assertThatThrownBy(() -> service.createParameter(parameterRequest()))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate parameter code");
        verify(parameterRepository, never()).save(any());
    }

    @Test
    void createParameterDuplicateNameIsRejected() {
        when(parameterRepository.existsByOrganizationIdAndBranchIdAndParameterName(
                        organizationId, branchId, "Total Bilirubin"))
                .thenReturn(true);

        assertThatThrownBy(() -> service.createParameter(parameterRequest()))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate parameter name");
        verify(parameterRepository, never()).save(any());
    }

    @Test
    void createParameterSucceeds() {
        when(parameterRepository.save(any(ParameterMaster.class))).thenAnswer(invocation -> {
            ParameterMaster parameter = invocation.getArgument(0);
            parameter.setId(parameterId);
            return parameter;
        });

        ParameterResponse response = service.createParameter(parameterRequest());

        assertThat(response.id()).isEqualTo(parameterId);
        assertThat(response.parameterCode()).isEqualTo("TBIL");
        assertThat(response.unit()).isEqualTo("mg/dL");
        assertThat(response.defaultReferenceRange()).isEqualTo("0.3 - 1.2");
        verify(parameterRepository).save(argThat(ParameterMaster::isActive));
    }

    // --- create reference range (API-112 / API-114, 116-119) ---

    @Test
    void createRangeMissingParameterIdIsRejected() {
        var request = new CreateReferenceRangeRequest(
                organizationId, branchId, null, null, null, null, null, null, null, null, null, null, null, null, null);

        assertThatThrownBy(() -> service.createReferenceRange(request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("parameterId is required");
    }

    @Test
    void createRangeUnknownGenderIsRejected() {
        var request = new CreateReferenceRangeRequest(
                organizationId, branchId, parameterId, "OTHER", null, null, null, null, null, null, null, null, null,
                null, null);

        assertThatThrownBy(() -> service.createReferenceRange(request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Invalid gender");
    }

    @Test
    void createRangeInvalidAgeRangeIsRejected() {
        var request = rangeRequest(BigDecimal.valueOf(50), BigDecimal.TEN, null, null, null, null);

        assertThatThrownBy(() -> service.createReferenceRange(request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Invalid age range");
        verifyNoInteractions(scopeGuard, referenceRangeRepository);
    }

    @Test
    void createRangeInvalidEffectiveDatesAreRejected() {
        var request = rangeRequest(null, null, null, null, LocalDate.of(2024, 1, 1), LocalDate.of(2023, 1, 1));

        assertThatThrownBy(() -> service.createReferenceRange(request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Invalid effective date range");
    }

    @Test
    void createRangeInvalidReferenceBoundsAreRejected() {
        var request = rangeRequest(null, null, new BigDecimal("17.0"), new BigDecimal("13.0"), null, null);

        assertThatThrownBy(() -> service.createReferenceRange(request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Invalid reference bounds");
    }

    @Test
    void createRangeUnknownParameterIsRejected() {
        stubParameterExists(false);

        assertThatThrownBy(() -> service.createReferenceRange(validRangeRequest()))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Parameter not found");
        verifyNoInteractions(referenceRangeRepository);
    }

    @Test
    void createRangeOverlapFromTriggerBecomes409() {
        stubParameterExists(true);
        when(referenceRangeRepository.saveAndFlush(any())).thenThrow(new DataIntegrityViolationException(
                "could not execute statement",
                new RuntimeException("ERROR: reference_range_master: overlapping demographic band for parameter_id=x")));

        assertThatThrownBy(() -> service.createReferenceRange(validRangeRequest()))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Overlapping demographic band");
    }

    @Test
    void createRangeOtherDatabaseFailureIsNotMaskedAsConflict() {
        stubParameterExists(true);
        var failure = new DataIntegrityViolationException("boom", new RuntimeException("connection reset"));
        when(referenceRangeRepository.saveAndFlush(any())).thenThrow(failure);

        assertThatThrownBy(() -> service.createReferenceRange(validRangeRequest())).isSameAs(failure);
    }

    @Test
    void createRangeAppliesContractDefaults() {
        stubParameterExists(true);
        when(referenceRangeRepository.saveAndFlush(any(ReferenceRangeMaster.class))).thenAnswer(invocation -> {
            ReferenceRangeMaster range = invocation.getArgument(0);
            range.setId(rangeId);
            return range;
        });
        var request = new CreateReferenceRangeRequest(
                organizationId, branchId, parameterId, null, null, null, null, null, null, null, null, null, null,
                null, null);

        ReferenceRangeResponse response = service.createReferenceRange(request);

        assertThat(response.id()).isEqualTo(rangeId);
        assertThat(response.gender()).isEqualTo("ANY");
        assertThat(response.ageMin()).isEqualByComparingTo("0");
        assertThat(response.ageMax()).isEqualByComparingTo("150");
        assertThat(response.ageUnit()).isEqualTo("YEARS");
        assertThat(response.pregnancyFlag()).isFalse();
        assertThat(response.effectiveFrom()).isEqualTo(LocalDate.now());
    }

    // --- lookup (API-113) ---

    @Test
    void lookupMissingGenderIsRejected() {
        var query = new ReferenceRangeLookupQuery(parameterId, null, BigDecimal.valueOf(30), "YEARS", null, null);

        assertThatThrownBy(() -> service.lookup(organizationId, branchId, query))
                .isInstanceOf(ValidationException.class)
                .hasMessage("gender is required");
        verifyNoInteractions(referenceRangeRepository);
    }

    @Test
    void lookupWithNoMatchingBandIsRejected() {
        when(referenceRangeRepository.lookup(any(), any(), any(), any(), any(), eq(false), any(), any(), any()))
                .thenReturn(List.of());
        var query = new ReferenceRangeLookupQuery(parameterId, "MALE", BigDecimal.valueOf(30), "YEARS", null, null);

        assertThatThrownBy(() -> service.lookup(organizationId, branchId, query))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("No matching reference range found");
    }

    @Test
    void lookupReturnsMatchingBandAndDefaultsDateAndPregnancy() {
        ReferenceRangeMaster band = new ReferenceRangeMaster();
        band.setReferenceMin(new BigDecimal("13.0"));
        band.setReferenceMax(new BigDecimal("17.0"));
        band.setReferenceRange("13.0 - 17.0");
        band.setCriticalLow(new BigDecimal("7.0"));
        band.setCriticalHigh(new BigDecimal("20.0"));
        band.setEffectiveFrom(LocalDate.of(2020, 1, 1));
        when(referenceRangeRepository.lookup(
                        organizationId, branchId, parameterId, "MALE", "YEARS", false, BigDecimal.valueOf(30),
                        LocalDate.now(), Limit.of(1)))
                .thenReturn(List.of(band));

        ReferenceRangeLookupResponse response = service.lookup(organizationId, branchId,
                new ReferenceRangeLookupQuery(parameterId, "MALE", BigDecimal.valueOf(30), "YEARS", null, null));

        assertThat(response.referenceRange()).isEqualTo("13.0 - 17.0");
        assertThat(response.criticalHigh()).isEqualByComparingTo("20.0");
        assertThat(response.effectiveFrom()).isEqualTo(LocalDate.of(2020, 1, 1));
        assertThat(response.effectiveTo()).isNull();
    }
}
