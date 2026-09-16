package com.x46.backend.identity.controller;

import com.x46.backend.common.ApiResponse;
import com.x46.backend.identity.dto.CreateUserRequest;
import com.x46.backend.identity.dto.OrganizationUserResponse;
import com.x46.backend.identity.dto.UpdateUserRequest;
import com.x46.backend.identity.dto.UserDetailResponse;
import com.x46.backend.identity.dto.UserResponse;
import com.x46.backend.identity.dto.UserStatusRequest;
import com.x46.backend.identity.dto.UserStatusResponse;
import com.x46.backend.identity.dto.UserSummaryResponse;
import com.x46.backend.identity.dto.UserUpdateResponse;
import com.x46.backend.identity.service.UserService;
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
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/api/organizations/{organizationId}/branches/{branchId}/users")
    @PreAuthorize("@perm.can('User Management', 'CREATE')")
    public ResponseEntity<ApiResponse<UserResponse>> create(
            @PathVariable UUID organizationId, @PathVariable UUID branchId, @RequestBody CreateUserRequest request) {
        UserResponse response = userService.create(organizationId, branchId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("User created successfully", response));
    }

    @GetMapping("/api/organizations/{organizationId}/users")
    @PreAuthorize("hasRole('PLATFORM_ADMIN')")
    public ResponseEntity<ApiResponse<List<OrganizationUserResponse>>> listByOrganization(
            @PathVariable UUID organizationId) {
        List<OrganizationUserResponse> response = userService.listByOrganization(organizationId);
        return ResponseEntity.ok(ApiResponse.ok("Users fetched successfully", response));
    }

    @GetMapping("/api/organizations/{organizationId}/branches/{branchId}/users")
    @PreAuthorize("@perm.can('User Management', 'VIEW')")
    public ResponseEntity<ApiResponse<List<UserSummaryResponse>>> list(
            @PathVariable UUID organizationId,
            @PathVariable UUID branchId,
            @RequestParam(required = false) Boolean isActive,
            @RequestParam(required = false) String search) {
        List<UserSummaryResponse> response = userService.list(organizationId, branchId, isActive, search);
        return ResponseEntity.ok(ApiResponse.ok("Users fetched successfully", response));
    }

    @GetMapping("/api/organizations/{organizationId}/branches/{branchId}/users/{userId}")
    @PreAuthorize("@perm.can('User Management', 'VIEW')")
    public ResponseEntity<ApiResponse<UserDetailResponse>> view(
            @PathVariable UUID organizationId, @PathVariable UUID branchId, @PathVariable UUID userId) {
        UserDetailResponse response = userService.view(organizationId, branchId, userId);
        return ResponseEntity.ok(ApiResponse.ok("User fetched successfully", response));
    }

    @PutMapping("/api/organizations/{organizationId}/branches/{branchId}/users/{userId}")
    @PreAuthorize("@perm.can('User Management', 'UPDATE')")
    public ResponseEntity<ApiResponse<UserUpdateResponse>> update(
            @PathVariable UUID organizationId,
            @PathVariable UUID branchId,
            @PathVariable UUID userId,
            @RequestBody UpdateUserRequest request) {
        UserUpdateResponse response = userService.update(organizationId, branchId, userId, request);
        return ResponseEntity.ok(ApiResponse.ok("User updated successfully", response));
    }

    @PatchMapping("/api/organizations/{organizationId}/branches/{branchId}/users/{userId}/status")
    @PreAuthorize("@perm.can('User Management', 'UPDATE')")
    public ResponseEntity<ApiResponse<UserStatusResponse>> updateStatus(
            @PathVariable UUID organizationId,
            @PathVariable UUID branchId,
            @PathVariable UUID userId,
            @RequestBody UserStatusRequest request) {
        UserStatusResponse response = userService.updateStatus(organizationId, branchId, userId, request);
        return ResponseEntity.ok(ApiResponse.ok("User status updated successfully", response));
    }
}
