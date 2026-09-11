package com.x46.backend.org;

import com.x46.backend.common.ApiResponse;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class BranchController {

    private final BranchService branchService;

    public BranchController(BranchService branchService) {
        this.branchService = branchService;
    }

    @PostMapping("/api/organizations/{organizationId}/branches")
    @PreAuthorize("hasRole('PLATFORM_ADMIN')")
    public ResponseEntity<ApiResponse<BranchResponse>> create(
            @PathVariable UUID organizationId, @RequestBody CreateBranchRequest request) {
        BranchResponse response = branchService.create(organizationId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("Branch created successfully", response));
    }
}
