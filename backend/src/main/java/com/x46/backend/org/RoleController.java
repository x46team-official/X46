package com.x46.backend.org;

import com.x46.backend.common.ApiResponse;
import java.util.List;
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class RoleController {

    private final RoleService roleService;

    public RoleController(RoleService roleService) {
        this.roleService = roleService;
    }

    @PostMapping("/api/organizations/{organizationId}/branches/{branchId}/roles")
    @PreAuthorize("@perm.can('Role Management', 'CREATE')")
    public ResponseEntity<ApiResponse<RoleResponse>> create(
            @PathVariable UUID organizationId, @PathVariable UUID branchId, @RequestBody CreateRoleRequest request) {
        RoleResponse response = roleService.create(organizationId, branchId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("Role created successfully", response));
    }

    @GetMapping("/api/organizations/{organizationId}/branches/{branchId}/roles")
    @PreAuthorize("@perm.can('Role Management', 'VIEW')")
    public ResponseEntity<ApiResponse<List<RoleSummaryResponse>>> list(
            @PathVariable UUID organizationId,
            @PathVariable UUID branchId,
            @RequestParam(required = false) String search) {
        List<RoleSummaryResponse> response = roleService.list(organizationId, branchId, search);
        return ResponseEntity.ok(ApiResponse.ok("Roles fetched successfully", response));
    }

    @GetMapping("/api/organizations/{organizationId}/branches/{branchId}/roles/{roleId}")
    @PreAuthorize("@perm.can('Role Management', 'VIEW')")
    public ResponseEntity<ApiResponse<RoleDetailResponse>> view(
            @PathVariable UUID organizationId, @PathVariable UUID branchId, @PathVariable UUID roleId) {
        RoleDetailResponse response = roleService.view(organizationId, branchId, roleId);
        return ResponseEntity.ok(ApiResponse.ok("Role fetched successfully", response));
    }

    @PutMapping("/api/organizations/{organizationId}/branches/{branchId}/roles/{roleId}")
    @PreAuthorize("@perm.can('Role Management', 'UPDATE')")
    public ResponseEntity<ApiResponse<RoleSummaryResponse>> update(
            @PathVariable UUID organizationId,
            @PathVariable UUID branchId,
            @PathVariable UUID roleId,
            @RequestBody UpdateRoleRequest request) {
        RoleSummaryResponse response = roleService.update(organizationId, branchId, roleId, request);
        return ResponseEntity.ok(ApiResponse.ok("Role updated successfully", response));
    }

    @PatchMapping("/api/organizations/{organizationId}/branches/{branchId}/roles/{roleId}/status")
    @PreAuthorize("@perm.can('Role Management', 'UPDATE')")
    public ResponseEntity<ApiResponse<RoleStatusResponse>> updateStatus(
            @PathVariable UUID organizationId,
            @PathVariable UUID branchId,
            @PathVariable UUID roleId,
            @RequestBody RoleStatusRequest request) {
        RoleStatusResponse response = roleService.updateStatus(organizationId, branchId, roleId, request);
        return ResponseEntity.ok(ApiResponse.ok("Role status updated successfully", response));
    }
}
