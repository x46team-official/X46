package com.x46.backend.master.controller;

import com.x46.backend.common.ApiResponse;
import com.x46.backend.master.dto.CreateTestRequest;
import com.x46.backend.master.dto.TestListItemResponse;
import com.x46.backend.master.dto.TestResponse;
import com.x46.backend.master.dto.TestSearchItemResponse;
import com.x46.backend.master.dto.TestStatusRequest;
import com.x46.backend.master.dto.TestStatusResponse;
import com.x46.backend.master.dto.TestUpdateResponse;
import com.x46.backend.master.dto.UpdateTestRequest;
import com.x46.backend.master.service.TestService;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
public class TestController {

    private final TestService testService;

    public TestController(TestService testService) {
        this.testService = testService;
    }

    @PostMapping("/api/organizations/{organizationId}/branches/{branchId}/tests")
    @PreAuthorize("@perm.can('Test Management', 'CREATE')")
    public ResponseEntity<ApiResponse<TestResponse>> create(
            @PathVariable UUID organizationId, @PathVariable UUID branchId, @RequestBody CreateTestRequest request) {
        TestResponse response = testService.create(organizationId, branchId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("Test created successfully", response));
    }

    @GetMapping("/api/organizations/{organizationId}/branches/{branchId}/tests")
    @PreAuthorize("@perm.can('Test Management', 'VIEW')")
    public ResponseEntity<ApiResponse<List<TestListItemResponse>>> list(
            @PathVariable UUID organizationId, @PathVariable UUID branchId) {
        List<TestListItemResponse> response = testService.list(organizationId, branchId);
        return ResponseEntity.ok(ApiResponse.ok("Tests fetched successfully", response));
    }

    @GetMapping("/api/organizations/{organizationId}/branches/{branchId}/tests/search")
    @PreAuthorize("@perm.can('Test Management', 'VIEW')")
    public ResponseEntity<ApiResponse<List<TestSearchItemResponse>>> search(
            @PathVariable UUID organizationId,
            @PathVariable UUID branchId,
            @RequestParam(required = false) String query) {
        List<TestSearchItemResponse> response = testService.search(organizationId, branchId, query);
        return ResponseEntity.ok(ApiResponse.ok("Tests searched successfully", response));
    }

    @GetMapping("/api/organizations/{organizationId}/branches/{branchId}/tests/{testId}")
    @PreAuthorize("@perm.can('Test Management', 'VIEW')")
    public ResponseEntity<ApiResponse<TestResponse>> view(
            @PathVariable UUID organizationId, @PathVariable UUID branchId, @PathVariable UUID testId) {
        TestResponse response = testService.view(organizationId, branchId, testId);
        return ResponseEntity.ok(ApiResponse.ok("Test fetched successfully", response));
    }

    @PutMapping("/api/organizations/{organizationId}/branches/{branchId}/tests/{testId}")
    @PreAuthorize("@perm.can('Test Management', 'UPDATE')")
    public ResponseEntity<ApiResponse<TestUpdateResponse>> update(
            @PathVariable UUID organizationId,
            @PathVariable UUID branchId,
            @PathVariable UUID testId,
            @RequestBody UpdateTestRequest request) {
        TestUpdateResponse response = testService.update(organizationId, branchId, testId, request);
        return ResponseEntity.ok(ApiResponse.ok("Test updated successfully", response));
    }

    @PatchMapping("/api/organizations/{organizationId}/branches/{branchId}/tests/{testId}/status")
    @PreAuthorize("@perm.can('Test Management', 'UPDATE')")
    public ResponseEntity<ApiResponse<TestStatusResponse>> updateStatus(
            @PathVariable UUID organizationId,
            @PathVariable UUID branchId,
            @PathVariable UUID testId,
            @RequestBody TestStatusRequest request) {
        TestStatusResponse response = testService.updateStatus(organizationId, branchId, testId, request);
        return ResponseEntity.ok(ApiResponse.ok("Test status updated successfully", response));
    }
}
