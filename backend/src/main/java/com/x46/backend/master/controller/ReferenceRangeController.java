package com.x46.backend.master.controller;

import com.x46.backend.common.ApiResponse;
import com.x46.backend.master.dto.CreateParameterRequest;
import com.x46.backend.master.dto.CreateReferenceRangeRequest;
import com.x46.backend.master.dto.ParameterResponse;
import com.x46.backend.master.dto.ReferenceRangeLookupQuery;
import com.x46.backend.master.dto.ReferenceRangeLookupResponse;
import com.x46.backend.master.dto.ReferenceRangeResponse;
import com.x46.backend.master.service.ReferenceRangeService;
import com.x46.backend.security.JwtPrincipal;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ReferenceRangeController {

    private final ReferenceRangeService referenceRangeService;

    public ReferenceRangeController(ReferenceRangeService referenceRangeService) {
        this.referenceRangeService = referenceRangeService;
    }

    @PostMapping("/api/parameters")
    @PreAuthorize("@perm.can('Reference Range Master', 'CREATE')")
    public ResponseEntity<ApiResponse<ParameterResponse>> createParameter(@RequestBody CreateParameterRequest request) {
        ParameterResponse response = referenceRangeService.createParameter(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("Parameter created successfully", response));
    }

    @PostMapping("/api/reference-ranges")
    @PreAuthorize("@perm.can('Reference Range Master', 'CREATE')")
    public ResponseEntity<ApiResponse<ReferenceRangeResponse>> createReferenceRange(
            @RequestBody CreateReferenceRangeRequest request) {
        ReferenceRangeResponse response = referenceRangeService.createReferenceRange(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Reference range created successfully", response));
    }

    // API-113 requires org + branch but defines no parameter for them, so they come from the caller's JWT.
    @GetMapping("/api/reference-ranges/lookup")
    @PreAuthorize("@perm.can('Reference Range Master', 'VIEW')")
    public ResponseEntity<ApiResponse<ReferenceRangeLookupResponse>> lookup(
            @AuthenticationPrincipal JwtPrincipal principal, ReferenceRangeLookupQuery query) {
        ReferenceRangeLookupResponse response =
                referenceRangeService.lookup(principal.organizationId(), principal.branchId(), query);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }
}
