package com.x46.backend.identity.controller;

import com.x46.backend.common.ApiResponse;
import com.x46.backend.identity.dto.BootstrapAdminRequest;
import com.x46.backend.identity.dto.BootstrapAdminResponse;
import com.x46.backend.identity.service.OrganizationBootstrapService;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class OrganizationBootstrapController {

    private final OrganizationBootstrapService organizationBootstrapService;

    public OrganizationBootstrapController(OrganizationBootstrapService organizationBootstrapService) {
        this.organizationBootstrapService = organizationBootstrapService;
    }

    @PostMapping("/api/organizations/{organizationId}/branches/{branchId}/bootstrap-admin")
    @PreAuthorize("hasRole('PLATFORM_ADMIN')")
    public ResponseEntity<ApiResponse<BootstrapAdminResponse>> bootstrap(
            @PathVariable UUID organizationId, @PathVariable UUID branchId, @RequestBody BootstrapAdminRequest request) {
        BootstrapAdminResponse response = organizationBootstrapService.bootstrap(organizationId, branchId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Admin user bootstrapped successfully", response));
    }
}
