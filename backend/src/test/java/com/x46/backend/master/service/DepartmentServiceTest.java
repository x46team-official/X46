package com.x46.backend.master.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.NotFoundException;
import com.x46.backend.common.ScopeGuard;
import com.x46.backend.common.ValidationException;
import com.x46.backend.master.dto.CreateDepartmentRequest;
import com.x46.backend.master.dto.DepartmentDetailResponse;
import com.x46.backend.master.dto.DepartmentResponse;
import com.x46.backend.master.dto.DepartmentStatusRequest;
import com.x46.backend.master.dto.DepartmentStatusResponse;
import com.x46.backend.master.dto.DepartmentUpdateResponse;
import com.x46.backend.master.dto.UpdateDepartmentRequest;
import com.x46.backend.master.entity.DepartmentMaster;
import com.x46.backend.master.repository.DepartmentMasterRepository;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class DepartmentServiceTest {

    @Mock
    private DepartmentMasterRepository departmentRepository;

    @Mock
    private ScopeGuard scopeGuard;

    private DepartmentService departmentService;

    private final UUID organizationId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();
    private final UUID departmentId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        departmentService = new DepartmentService(departmentRepository, scopeGuard);
    }

    private DepartmentMaster existingDepartment() {
        DepartmentMaster department = new DepartmentMaster();
        department.setId(departmentId);
        department.setOrganizationId(organizationId);
        department.setBranchId(branchId);
        department.setDepartmentCode("BIO");
        department.setDepartmentName("Biochemistry");
        department.setDescription("Biochemistry Department");
        department.setActive(true);
        return department;
    }

    private void stubFound() {
        when(departmentRepository.findByIdAndOrganizationIdAndBranchId(departmentId, organizationId, branchId))
                .thenReturn(Optional.of(existingDepartment()));
    }

    private void stubNotFound() {
        when(departmentRepository.findByIdAndOrganizationIdAndBranchId(departmentId, organizationId, branchId))
                .thenReturn(Optional.empty());
    }

    private void stubSaveEchoesEntity() {
        when(departmentRepository.save(any(DepartmentMaster.class))).thenAnswer(invocation -> {
            DepartmentMaster department = invocation.getArgument(0);
            if (department.getId() == null) {
                department.setId(departmentId);
            }
            return department;
        });
    }

    // --- create (API-012) ---

    @Test
    void createMissingCodeIsRejected() {
        var request = new CreateDepartmentRequest(null, "Biochemistry", null);

        assertThatThrownBy(() -> departmentService.create(organizationId, branchId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Validation error");
        verifyNoInteractions(scopeGuard, departmentRepository);
    }

    @Test
    void createBlankNameIsRejected() {
        var request = new CreateDepartmentRequest("BIO", "  ", null);

        assertThatThrownBy(() -> departmentService.create(organizationId, branchId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Validation error");
        verifyNoInteractions(scopeGuard, departmentRepository);
    }

    @Test
    void createUnknownOrgOrBranchIsRejected() {
        doThrow(new NotFoundException("Organization or branch not found"))
                .when(scopeGuard).requireOrgBranch(organizationId, branchId);

        assertThatThrownBy(() -> departmentService.create(
                        organizationId, branchId, new CreateDepartmentRequest("BIO", "Biochemistry", null)))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization or branch not found");
        verifyNoInteractions(departmentRepository);
    }

    @Test
    void createDuplicateCodeIsRejected() {
        when(departmentRepository.existsByOrganizationIdAndBranchIdAndDepartmentCode(organizationId, branchId, "BIO"))
                .thenReturn(true);

        assertThatThrownBy(() -> departmentService.create(
                        organizationId, branchId, new CreateDepartmentRequest("BIO", "Biochemistry", null)))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate department code/name");
        verify(departmentRepository, never()).save(any());
    }

    @Test
    void createDuplicateNameIsRejected() {
        when(departmentRepository.existsByOrganizationIdAndBranchIdAndDepartmentName(
                        organizationId, branchId, "Biochemistry"))
                .thenReturn(true);

        assertThatThrownBy(() -> departmentService.create(
                        organizationId, branchId, new CreateDepartmentRequest("BIO", "Biochemistry", null)))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate department code/name");
        verify(departmentRepository, never()).save(any());
    }

    @Test
    void createSucceedsAndDefaultsToActive() {
        stubSaveEchoesEntity();

        DepartmentResponse response = departmentService.create(
                organizationId, branchId, new CreateDepartmentRequest("BIO", "Biochemistry", "Biochemistry Department"));

        assertThat(response.id()).isEqualTo(departmentId);
        assertThat(response.organizationId()).isEqualTo(organizationId);
        assertThat(response.branchId()).isEqualTo(branchId);
        assertThat(response.departmentCode()).isEqualTo("BIO");
        assertThat(response.departmentName()).isEqualTo("Biochemistry");
        assertThat(response.isActive()).isTrue();
    }

    // --- view (API-013) ---

    @Test
    void viewNotFoundOrOutOfScopeIsRejected() {
        stubNotFound();

        assertThatThrownBy(() -> departmentService.view(organizationId, branchId, departmentId))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Department not found");
    }

    @Test
    void viewReturnsDepartmentWithDescription() {
        stubFound();

        DepartmentDetailResponse response = departmentService.view(organizationId, branchId, departmentId);

        assertThat(response.id()).isEqualTo(departmentId);
        assertThat(response.departmentCode()).isEqualTo("BIO");
        assertThat(response.description()).isEqualTo("Biochemistry Department");
        assertThat(response.isActive()).isTrue();
    }

    // --- update (API-014) ---

    @Test
    void updateMissingNameIsRejected() {
        assertThatThrownBy(() -> departmentService.update(
                        organizationId, branchId, departmentId, new UpdateDepartmentRequest("BIO", null, null)))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Validation error");
        verifyNoInteractions(departmentRepository);
    }

    @Test
    void updateNotFoundIsRejected() {
        stubNotFound();

        assertThatThrownBy(() -> departmentService.update(
                        organizationId, branchId, departmentId, new UpdateDepartmentRequest("BIO", "Biochem", null)))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Department not found");
    }

    @Test
    void updateCollidingWithAnotherDepartmentIsRejected() {
        stubFound();
        when(departmentRepository.existsByOrganizationIdAndBranchIdAndDepartmentNameAndIdNot(
                        organizationId, branchId, "Haematology", departmentId))
                .thenReturn(true);

        assertThatThrownBy(() -> departmentService.update(
                        organizationId, branchId, departmentId, new UpdateDepartmentRequest("BIO", "Haematology", null)))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate department code/name");
        verify(departmentRepository, never()).save(any());
    }

    @Test
    void updateSucceedsAndKeepsDescriptionWhenOmitted() {
        stubFound();
        stubSaveEchoesEntity();

        DepartmentUpdateResponse response = departmentService.update(
                organizationId, branchId, departmentId, new UpdateDepartmentRequest("BIO", "Biochemistry Updated", null));

        assertThat(response.id()).isEqualTo(departmentId);
        assertThat(response.departmentName()).isEqualTo("Biochemistry Updated");
        assertThat(response.isActive()).isTrue();
        verify(departmentRepository).save(org.mockito.ArgumentMatchers.argThat(
                d -> "Biochemistry Department".equals(d.getDescription()) && d.getUpdatedAt() != null));
    }

    // --- status (API-015) ---

    @Test
    void statusMissingIsActiveIsRejected() {
        assertThatThrownBy(() -> departmentService.updateStatus(
                        organizationId, branchId, departmentId, new DepartmentStatusRequest(null)))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Invalid status value");
        verifyNoInteractions(departmentRepository);
    }

    @Test
    void statusNotFoundIsRejected() {
        stubNotFound();

        assertThatThrownBy(() -> departmentService.updateStatus(
                        organizationId, branchId, departmentId, new DepartmentStatusRequest(false)))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Department not found");
    }

    @Test
    void statusDeactivatesDepartment() {
        stubFound();
        stubSaveEchoesEntity();

        DepartmentStatusResponse response = departmentService.updateStatus(
                organizationId, branchId, departmentId, new DepartmentStatusRequest(false));

        assertThat(response.id()).isEqualTo(departmentId);
        assertThat(response.isActive()).isFalse();
    }
}
