package com.x46.backend.identity.controller;

import com.x46.backend.common.ApiResponse;
import com.x46.backend.identity.dto.AssignRoleRequest;
import com.x46.backend.identity.dto.UserRoleResponse;
import com.x46.backend.identity.service.UserRoleService;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class UserRoleController {

    private final UserRoleService userRoleService;

    public UserRoleController(UserRoleService userRoleService) {
        this.userRoleService = userRoleService;
    }

    @PostMapping("/api/organizations/{organizationId}/branches/{branchId}/users/{userId}/roles")
    @PreAuthorize("@perm.can('User Role Management', 'CREATE')")
    public ResponseEntity<ApiResponse<UserRoleResponse>> assign(
            @PathVariable UUID organizationId,
            @PathVariable UUID branchId,
            @PathVariable UUID userId,
            @RequestBody AssignRoleRequest request) {
        UserRoleResponse response = userRoleService.assign(organizationId, branchId, userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("User role assigned successfully", response));
    }
}
