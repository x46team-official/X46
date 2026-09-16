package com.x46.backend.org.controller;

import com.x46.backend.common.ApiResponse;
import com.x46.backend.org.dto.CreateOrganizationRequest;
import com.x46.backend.org.dto.OrganizationResponse;
import com.x46.backend.org.dto.OrganizationSummaryResponse;
import com.x46.backend.org.service.OrganizationService;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class OrganizationController {

    private final OrganizationService organizationService;

    public OrganizationController(OrganizationService organizationService) {
        this.organizationService = organizationService;
    }

    @PostMapping("/api/organizations")
    @PreAuthorize("hasRole('PLATFORM_ADMIN')")
    public ResponseEntity<ApiResponse<OrganizationResponse>> create(@RequestBody CreateOrganizationRequest request) {
        OrganizationResponse response = organizationService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Organization created successfully", response));
    }

    @GetMapping("/api/organizations")
    @PreAuthorize("hasRole('PLATFORM_ADMIN')")
    public ResponseEntity<ApiResponse<List<OrganizationSummaryResponse>>> list() {
        List<OrganizationSummaryResponse> response = organizationService.listWithCounts();
        return ResponseEntity.ok(ApiResponse.ok("Organizations retrieved successfully", response));
    }
}
