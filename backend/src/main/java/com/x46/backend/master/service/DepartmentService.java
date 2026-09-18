package com.x46.backend.master.service;

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
import java.time.OffsetDateTime;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class DepartmentService {

    private final DepartmentMasterRepository departmentRepository;
    private final ScopeGuard scopeGuard;

    DepartmentService(DepartmentMasterRepository departmentRepository, ScopeGuard scopeGuard) {
        this.departmentRepository = departmentRepository;
        this.scopeGuard = scopeGuard;
    }

    public DepartmentResponse create(UUID organizationId, UUID branchId, CreateDepartmentRequest request) {
        requireCodeAndName(request.departmentCode(), request.departmentName());
        scopeGuard.requireOrgBranch(organizationId, branchId);
        if (departmentRepository.existsByOrganizationIdAndBranchIdAndDepartmentCode(
                        organizationId, branchId, request.departmentCode())
                || departmentRepository.existsByOrganizationIdAndBranchIdAndDepartmentName(
                        organizationId, branchId, request.departmentName())) {
            throw new ConflictException("Duplicate department code/name");
        }

        DepartmentMaster department = new DepartmentMaster();
        department.setOrganizationId(organizationId);
        department.setBranchId(branchId);
        department.setDepartmentCode(request.departmentCode());
        department.setDepartmentName(request.departmentName());
        department.setDescription(request.description());
        department.setActive(true);
        OffsetDateTime now = OffsetDateTime.now();
        department.setCreatedAt(now);
        department.setUpdatedAt(now);

        DepartmentMaster saved = departmentRepository.save(department);
        return new DepartmentResponse(
                saved.getId(),
                saved.getOrganizationId(),
                saved.getBranchId(),
                saved.getDepartmentCode(),
                saved.getDepartmentName(),
                saved.getActive());
    }

    public DepartmentDetailResponse view(UUID organizationId, UUID branchId, UUID departmentId) {
        DepartmentMaster department = findScoped(organizationId, branchId, departmentId);
        return new DepartmentDetailResponse(
                department.getId(),
                department.getOrganizationId(),
                department.getBranchId(),
                department.getDepartmentCode(),
                department.getDepartmentName(),
                department.getDescription(),
                department.getActive());
    }

    public DepartmentUpdateResponse update(
            UUID organizationId, UUID branchId, UUID departmentId, UpdateDepartmentRequest request) {
        requireCodeAndName(request.departmentCode(), request.departmentName());
        DepartmentMaster department = findScoped(organizationId, branchId, departmentId);
        if (departmentRepository.existsByOrganizationIdAndBranchIdAndDepartmentCodeAndIdNot(
                        organizationId, branchId, request.departmentCode(), departmentId)
                || departmentRepository.existsByOrganizationIdAndBranchIdAndDepartmentNameAndIdNot(
                        organizationId, branchId, request.departmentName(), departmentId)) {
            throw new ConflictException("Duplicate department code/name");
        }

        department.setDepartmentCode(request.departmentCode());
        department.setDepartmentName(request.departmentName());
        if (request.description() != null) {
            department.setDescription(request.description());
        }
        department.setUpdatedAt(OffsetDateTime.now());

        DepartmentMaster saved = departmentRepository.save(department);
        return new DepartmentUpdateResponse(
                saved.getId(), saved.getDepartmentCode(), saved.getDepartmentName(), saved.getActive());
    }

    public DepartmentStatusResponse updateStatus(
            UUID organizationId, UUID branchId, UUID departmentId, DepartmentStatusRequest request) {
        if (request.isActive() == null) {
            throw new ValidationException("Invalid status value");
        }
        DepartmentMaster department = findScoped(organizationId, branchId, departmentId);
        department.setActive(request.isActive());
        department.setUpdatedAt(OffsetDateTime.now());
        DepartmentMaster saved = departmentRepository.save(department);
        return new DepartmentStatusResponse(saved.getId(), saved.getActive());
    }

    // API-013/014/015 use one 404 for unknown org, unknown branch, unknown department and
    // out-of-scope department alike, so a single scoped lookup covers every case.
    private DepartmentMaster findScoped(UUID organizationId, UUID branchId, UUID departmentId) {
        return departmentRepository
                .findByIdAndOrganizationIdAndBranchId(departmentId, organizationId, branchId)
                .orElseThrow(() -> new NotFoundException("Department not found"));
    }

    private static void requireCodeAndName(String departmentCode, String departmentName) {
        if (isBlank(departmentCode) || isBlank(departmentName)) {
            throw new ValidationException("Validation error");
        }
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
