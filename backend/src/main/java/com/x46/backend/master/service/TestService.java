package com.x46.backend.master.service;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.NotFoundException;
import com.x46.backend.common.ScopeGuard;
import com.x46.backend.common.ValidationException;
import com.x46.backend.master.dto.CreateTestRequest;
import com.x46.backend.master.dto.TestListItemResponse;
import com.x46.backend.master.dto.TestResponse;
import com.x46.backend.master.dto.TestSearchItemResponse;
import com.x46.backend.master.dto.TestStatusRequest;
import com.x46.backend.master.dto.TestStatusResponse;
import com.x46.backend.master.dto.TestUpdateResponse;
import com.x46.backend.master.dto.UpdateTestRequest;
import com.x46.backend.master.entity.TestMaster;
import com.x46.backend.master.repository.TestMasterRepository;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class TestService {

    private final TestMasterRepository testMasterRepository;
    private final ScopeGuard scopeGuard;
    private final JdbcTemplate jdbcTemplate;

    TestService(TestMasterRepository testMasterRepository, ScopeGuard scopeGuard, JdbcTemplate jdbcTemplate) {
        this.testMasterRepository = testMasterRepository;
        this.scopeGuard = scopeGuard;
        this.jdbcTemplate = jdbcTemplate;
    }

    public TestResponse create(UUID organizationId, UUID branchId, CreateTestRequest request) {
        if (isBlank(request.testCode())) {
            throw new ValidationException("testCode is required");
        }
        if (isBlank(request.testName())) {
            throw new ValidationException("testName is required");
        }
        if (request.departmentId() == null) {
            throw new ValidationException("departmentId is required");
        }
        scopeGuard.requireBranch(organizationId, branchId);
        requireDepartment(organizationId, branchId, request.departmentId());
        if (testMasterRepository.existsByOrganizationIdAndBranchIdAndTestCode(
                organizationId, branchId, request.testCode())) {
            throw new ConflictException("Duplicate test code");
        }
        if (testMasterRepository.existsByOrganizationIdAndBranchIdAndTestName(
                organizationId, branchId, request.testName())) {
            throw new ConflictException("Duplicate test name");
        }

        TestMaster test = new TestMaster();
        test.setOrganizationId(organizationId);
        test.setBranchId(branchId);
        test.setDepartmentId(request.departmentId());
        test.setTestCode(request.testCode());
        test.setTestName(request.testName());
        test.setDisplayName(request.displayName());
        test.setPrintName(request.printName());
        test.setShortCode(request.shortCode());
        test.setSellingPrice(orZero(request.sellingPrice()));
        test.setCostPrice(orZero(request.costPrice()));
        test.setCprr(orZero(request.cprr()));
        test.setTestCategoryId(request.testCategoryId());
        test.setBillingCategoryId(request.billingCategoryId());
        test.setSampleTypeId(request.sampleTypeId());
        test.setPerformingLabId(request.performingLabId());
        test.setOutsourceCenterId(request.outsourceCenterId());
        test.setWorksheetId(request.worksheetId());
        test.setWorklistId(request.worklistId());
        test.setTestMethod(request.testMethod());
        test.setTestType(request.testType());
        test.setTatMinutes(request.tatMinutes() == null ? 0 : request.tatMinutes());
        test.setMachineTestCode(request.machineTestCode());
        test.setConsumptionGroup(request.consumptionGroup());
        test.setAutoApproval(Boolean.TRUE.equals(request.autoApproval()));
        test.setAutomaticallyAuthorize(Boolean.TRUE.equals(request.automaticallyAuthorize()));
        test.setNablAccredited(Boolean.TRUE.equals(request.nablAccredited()));
        test.setMarkAsProfile(Boolean.TRUE.equals(request.markAsProfile()));
        test.setTwoStepVerification(Boolean.TRUE.equals(request.twoStepVerification()));
        test.setAuthorizeOnlyByAuthorizer(Boolean.TRUE.equals(request.authorizeOnlyByAuthorizer()));
        test.setOutsourceTest(Boolean.TRUE.equals(request.outsourceTest()));
        test.setNotifyAccession(Boolean.TRUE.equals(request.notifyAccession()));
        test.setDescription(request.description());
        test.setActive(true);
        OffsetDateTime now = OffsetDateTime.now();
        test.setCreatedAt(now);
        test.setUpdatedAt(now);

        TestMaster saved = testMasterRepository.save(test);
        return toResponse(saved);
    }

    public List<TestListItemResponse> list(UUID organizationId, UUID branchId) {
        scopeGuard.requireOrgBranch(organizationId, branchId);
        return testMasterRepository.findByOrganizationIdAndBranchId(organizationId, branchId).stream()
                .map(test -> new TestListItemResponse(
                        test.getId(),
                        test.getTestCode(),
                        test.getTestName(),
                        test.getDepartmentId(),
                        test.getSellingPrice(),
                        test.getCostPrice(),
                        test.isActive()))
                .toList();
    }

    public List<TestSearchItemResponse> search(UUID organizationId, UUID branchId, String query) {
        if (isBlank(query)) {
            throw new ValidationException("Search query is required");
        }
        scopeGuard.requireOrgBranch(organizationId, branchId);
        return testMasterRepository.search(organizationId, branchId, query).stream()
                .map(test -> new TestSearchItemResponse(
                        test.getId(), test.getTestCode(), test.getTestName(), test.isActive()))
                .toList();
    }

    public TestResponse view(UUID organizationId, UUID branchId, UUID testId) {
        scopeGuard.requireOrg(organizationId);
        scopeGuard.requireBranch(organizationId, branchId);
        TestMaster test = testMasterRepository.findById(testId).orElseThrow(() -> new NotFoundException("Test not found"));
        if (!test.getOrganizationId().equals(organizationId) || !test.getBranchId().equals(branchId)) {
            throw new NotFoundException("Test not accessible");
        }
        return toResponse(test);
    }

    public TestUpdateResponse update(UUID organizationId, UUID branchId, UUID testId, UpdateTestRequest request) {
        if (isBlank(request.testCode())) {
            throw new ValidationException("testCode is required");
        }
        if (isBlank(request.testName())) {
            throw new ValidationException("testName is required");
        }
        if (request.departmentId() == null) {
            throw new ValidationException("departmentId is required");
        }
        TestMaster test = findScoped(organizationId, branchId, testId);
        requireDepartment(organizationId, branchId, request.departmentId());
        if (testMasterRepository.existsByOrganizationIdAndBranchIdAndTestNameAndIdNot(
                organizationId, branchId, request.testName(), testId)) {
            throw new ConflictException("Duplicate test name");
        }
        if (testMasterRepository.existsByOrganizationIdAndBranchIdAndTestCodeAndIdNot(
                organizationId, branchId, request.testCode(), testId)) {
            throw new ConflictException("Duplicate test code");
        }

        test.setDepartmentId(request.departmentId());
        test.setTestCode(request.testCode());
        test.setTestName(request.testName());
        if (request.sellingPrice() != null) {
            test.setSellingPrice(request.sellingPrice());
        }
        if (request.costPrice() != null) {
            test.setCostPrice(request.costPrice());
        }
        if (request.cprr() != null) {
            test.setCprr(request.cprr());
        }
        if (request.displayName() != null) {
            test.setDisplayName(request.displayName());
        }
        if (request.printName() != null) {
            test.setPrintName(request.printName());
        }
        if (request.shortCode() != null) {
            test.setShortCode(request.shortCode());
        }
        if (request.testMethod() != null) {
            test.setTestMethod(request.testMethod());
        }
        if (request.testType() != null) {
            test.setTestType(request.testType());
        }
        if (request.tatMinutes() != null) {
            test.setTatMinutes(request.tatMinutes());
        }
        if (request.description() != null) {
            test.setDescription(request.description());
        }
        test.setUpdatedAt(OffsetDateTime.now());

        TestMaster saved = testMasterRepository.save(test);
        return new TestUpdateResponse(
                saved.getId(),
                saved.getTestCode(),
                saved.getTestName(),
                saved.getSellingPrice(),
                saved.getCostPrice(),
                saved.getCprr(),
                saved.isActive());
    }

    public TestStatusResponse updateStatus(UUID organizationId, UUID branchId, UUID testId, TestStatusRequest request) {
        if (request.isActive() == null) {
            throw new ValidationException("Invalid status value");
        }
        TestMaster test = findScoped(organizationId, branchId, testId);
        test.setActive(request.isActive());
        test.setUpdatedAt(OffsetDateTime.now());
        TestMaster saved = testMasterRepository.save(test);
        return new TestStatusResponse(saved.getId(), saved.isActive());
    }

    private TestMaster findScoped(UUID organizationId, UUID branchId, UUID testId) {
        return testMasterRepository
                .findByIdAndOrganizationIdAndBranchId(testId, organizationId, branchId)
                .orElseThrow(() -> new NotFoundException("Test not found"));
    }

    private void requireDepartment(UUID organizationId, UUID branchId, UUID departmentId) {
        Boolean departmentExists = jdbcTemplate.queryForObject(
                "SELECT EXISTS(SELECT 1 FROM department_master WHERE id = ? AND organization_id = ? AND branch_id = ?)",
                Boolean.class, departmentId, organizationId, branchId);
        if (!Boolean.TRUE.equals(departmentExists)) {
            throw new NotFoundException("Department not found");
        }
    }

    private static BigDecimal orZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

    private static TestResponse toResponse(TestMaster test) {
        return new TestResponse(
                test.getId(),
                test.getOrganizationId(),
                test.getBranchId(),
                test.getDepartmentId(),
                test.getTestCode(),
                test.getTestName(),
                test.getSellingPrice(),
                test.getCostPrice(),
                test.getCprr(),
                test.isActive());
    }
}
