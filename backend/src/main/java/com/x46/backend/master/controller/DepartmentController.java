package com.x46.backend.master.controller;

import com.x46.backend.common.ApiResponse;
import com.x46.backend.master.dto.CreateDepartmentRequest;
import com.x46.backend.master.dto.DepartmentDetailResponse;
import com.x46.backend.master.dto.DepartmentResponse;
import com.x46.backend.master.dto.DepartmentStatusRequest;
import com.x46.backend.master.dto.DepartmentStatusResponse;
import com.x46.backend.master.dto.DepartmentUpdateResponse;
import com.x46.backend.master.dto.UpdateDepartmentRequest;
import com.x46.backend.master.service.DepartmentService;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class DepartmentController {

    private final DepartmentService departmentService;

    public DepartmentController(DepartmentService departmentService) {
        this.departmentService = departmentService;
    }

    @PostMapping("/api/organizations/{organizationId}/branches/{branchId}/departments")
    @PreAuthorize("@perm.can('Department Management', 'CREATE')")
    public ResponseEntity<ApiResponse<DepartmentResponse>> create(
            @PathVariable UUID organizationId,
            @PathVariable UUID branchId,
            @RequestBody CreateDepartmentRequest request) {
        DepartmentResponse response = departmentService.create(organizationId, branchId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Department created successfully", response));
    }

    @GetMapping("/api/organizations/{organizationId}/branches/{branchId}/departments/{departmentId}")
    @PreAuthorize("@perm.can('Department Management', 'VIEW')")
    public ResponseEntity<ApiResponse<DepartmentDetailResponse>> view(
            @PathVariable UUID organizationId, @PathVariable UUID branchId, @PathVariable UUID departmentId) {
        DepartmentDetailResponse response = departmentService.view(organizationId, branchId, departmentId);
        return ResponseEntity.ok(ApiResponse.ok("Department fetched successfully", response));
    }

    @PutMapping("/api/organizations/{organizationId}/branches/{branchId}/departments/{departmentId}")
    @PreAuthorize("@perm.can('Department Management', 'UPDATE')")
    public ResponseEntity<ApiResponse<DepartmentUpdateResponse>> update(
            @PathVariable UUID organizationId,
            @PathVariable UUID branchId,
            @PathVariable UUID departmentId,
            @RequestBody UpdateDepartmentRequest request) {
        DepartmentUpdateResponse response = departmentService.update(organizationId, branchId, departmentId, request);
        return ResponseEntity.ok(ApiResponse.ok("Department updated successfully", response));
    }

    @PatchMapping("/api/organizations/{organizationId}/branches/{branchId}/departments/{departmentId}/status")
    @PreAuthorize("@perm.can('Department Management', 'UPDATE')")
    public ResponseEntity<ApiResponse<DepartmentStatusResponse>> updateStatus(
            @PathVariable UUID organizationId,
            @PathVariable UUID branchId,
            @PathVariable UUID departmentId,
            @RequestBody DepartmentStatusRequest request) {
        DepartmentStatusResponse response =
                departmentService.updateStatus(organizationId, branchId, departmentId, request);
        return ResponseEntity.ok(ApiResponse.ok("Department status updated successfully", response));
    }
}
