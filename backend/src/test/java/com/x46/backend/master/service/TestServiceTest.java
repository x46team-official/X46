package com.x46.backend.master.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

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
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.jdbc.core.JdbcTemplate;

@ExtendWith(MockitoExtension.class)
class TestServiceTest {

    @Mock
    private TestMasterRepository testMasterRepository;

    @Mock
    private ScopeGuard scopeGuard;

    @Mock
    private JdbcTemplate jdbcTemplate;

    private TestService testService;

    private final UUID organizationId = UUID.randomUUID();
    private final UUID branchId = UUID.randomUUID();
    private final UUID departmentId = UUID.randomUUID();
    private final UUID testId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        testService = new TestService(testMasterRepository, scopeGuard, jdbcTemplate);
    }

    private CreateTestRequest createRequest() {
        return new CreateTestRequest(
                departmentId, "LFT001", "Liver Function Test", null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                null, null);
    }

    private void stubDepartmentExists(boolean exists) {
        when(jdbcTemplate.queryForObject(
                        anyString(), eq(Boolean.class), eq(departmentId), eq(organizationId), eq(branchId)))
                .thenReturn(exists);
    }

    private TestMaster existingTest() {
        TestMaster test = new TestMaster();
        test.setId(testId);
        test.setOrganizationId(organizationId);
        test.setBranchId(branchId);
        test.setDepartmentId(departmentId);
        test.setTestCode("LFT001");
        test.setTestName("Liver Function Test");
        test.setSellingPrice(BigDecimal.valueOf(600));
        test.setCostPrice(BigDecimal.valueOf(350));
        test.setCprr(BigDecimal.ZERO);
        test.setActive(true);
        return test;
    }

    // --- create (API-006) ---

    @Test
    void createMissingTestCodeIsRejected() {
        var request = new CreateTestRequest(
                departmentId, null, "Liver Function Test", null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                null, null);

        assertThatThrownBy(() -> testService.create(organizationId, branchId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("testCode is required");
        verifyNoInteractions(scopeGuard, testMasterRepository);
    }

    @Test
    void createMissingTestNameIsRejected() {
        var request = new CreateTestRequest(
                departmentId, "LFT001", null, null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                null, null);

        assertThatThrownBy(() -> testService.create(organizationId, branchId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("testName is required");
        verifyNoInteractions(scopeGuard, testMasterRepository);
    }

    @Test
    void createMissingDepartmentIdIsRejected() {
        var request = new CreateTestRequest(
                null, "LFT001", "Liver Function Test", null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                null, null);

        assertThatThrownBy(() -> testService.create(organizationId, branchId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("departmentId is required");
        verifyNoInteractions(scopeGuard, testMasterRepository);
    }

    @Test
    void createUnknownBranchIsRejected() {
        doThrow(new NotFoundException("Branch not found")).when(scopeGuard).requireBranch(organizationId, branchId);

        assertThatThrownBy(() -> testService.create(organizationId, branchId, createRequest()))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Branch not found");
    }

    @Test
    void createUnknownDepartmentIsRejected() {
        stubDepartmentExists(false);

        assertThatThrownBy(() -> testService.create(organizationId, branchId, createRequest()))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Department not found");
    }

    @Test
    void createDuplicateTestCodeIsRejected() {
        stubDepartmentExists(true);
        when(testMasterRepository.existsByOrganizationIdAndBranchIdAndTestCode(organizationId, branchId, "LFT001"))
                .thenReturn(true);

        assertThatThrownBy(() -> testService.create(organizationId, branchId, createRequest()))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate test code");
    }

    @Test
    void createDuplicateTestNameIsRejected() {
        stubDepartmentExists(true);
        when(testMasterRepository.existsByOrganizationIdAndBranchIdAndTestName(
                        organizationId, branchId, "Liver Function Test"))
                .thenReturn(true);

        assertThatThrownBy(() -> testService.create(organizationId, branchId, createRequest()))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate test name");
    }

    @Test
    void createSucceeds() {
        stubDepartmentExists(true);
        when(testMasterRepository.save(any())).thenAnswer(invocation -> {
            TestMaster test = invocation.getArgument(0);
            test.setId(testId);
            return test;
        });

        TestResponse response = testService.create(organizationId, branchId, createRequest());

        assertThat(response.id()).isEqualTo(testId);
        assertThat(response.organizationId()).isEqualTo(organizationId);
        assertThat(response.branchId()).isEqualTo(branchId);
        assertThat(response.departmentId()).isEqualTo(departmentId);
        assertThat(response.testCode()).isEqualTo("LFT001");
        assertThat(response.testName()).isEqualTo("Liver Function Test");
        assertThat(response.sellingPrice()).isEqualByComparingTo(BigDecimal.ZERO);
        assertThat(response.isActive()).isTrue();
    }

    // --- list (API-010) ---

    @Test
    void listUnknownOrgOrBranchIsRejected() {
        doThrow(new NotFoundException("Organization or branch not found"))
                .when(scopeGuard).requireOrgBranch(organizationId, branchId);

        assertThatThrownBy(() -> testService.list(organizationId, branchId))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization or branch not found");
    }

    @Test
    void listSucceeds() {
        when(testMasterRepository.findByOrganizationIdAndBranchId(organizationId, branchId))
                .thenReturn(List.of(existingTest()));

        List<TestListItemResponse> response = testService.list(organizationId, branchId);

        assertThat(response).hasSize(1);
        assertThat(response.get(0).testCode()).isEqualTo("LFT001");
        assertThat(response.get(0).departmentId()).isEqualTo(departmentId);
        assertThat(response.get(0).sellingPrice()).isEqualByComparingTo(BigDecimal.valueOf(600));
        assertThat(response.get(0).isActive()).isTrue();
    }

    @Test
    void listIncludesInactiveTests() {
        TestMaster inactive = existingTest();
        inactive.setActive(false);
        when(testMasterRepository.findByOrganizationIdAndBranchId(organizationId, branchId))
                .thenReturn(List.of(inactive));

        List<TestListItemResponse> response = testService.list(organizationId, branchId);

        assertThat(response).hasSize(1);
        assertThat(response.get(0).isActive()).isFalse();
    }

    @Test
    void listWithNoTestsReturnsEmptyList() {
        when(testMasterRepository.findByOrganizationIdAndBranchId(organizationId, branchId))
                .thenReturn(List.of());

        assertThat(testService.list(organizationId, branchId)).isEmpty();
    }

    // --- search (API-011) ---

    @Test
    void searchMissingQueryIsRejected() {
        assertThatThrownBy(() -> testService.search(organizationId, branchId, null))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Search query is required");
        verifyNoInteractions(scopeGuard, testMasterRepository);
    }

    @Test
    void searchBlankQueryIsRejected() {
        assertThatThrownBy(() -> testService.search(organizationId, branchId, "   "))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Search query is required");
        verifyNoInteractions(scopeGuard, testMasterRepository);
    }

    @Test
    void searchUnknownOrgOrBranchIsRejected() {
        doThrow(new NotFoundException("Organization or branch not found"))
                .when(scopeGuard).requireOrgBranch(organizationId, branchId);

        assertThatThrownBy(() -> testService.search(organizationId, branchId, "lft"))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization or branch not found");
    }

    @Test
    void searchSucceeds() {
        when(testMasterRepository.search(organizationId, branchId, "lft")).thenReturn(List.of(existingTest()));

        List<TestSearchItemResponse> response = testService.search(organizationId, branchId, "lft");

        assertThat(response).hasSize(1);
        assertThat(response.get(0).testCode()).isEqualTo("LFT001");
        assertThat(response.get(0).testName()).isEqualTo("Liver Function Test");
        assertThat(response.get(0).isActive()).isTrue();
    }

    @Test
    void searchWithNoMatchesReturnsEmptyList() {
        when(testMasterRepository.search(organizationId, branchId, "zzz")).thenReturn(List.of());

        assertThat(testService.search(organizationId, branchId, "zzz")).isEmpty();
    }

    // --- view (API-007) ---

    @Test
    void viewUnknownOrganizationIsRejected() {
        doThrow(new NotFoundException("Organization not found")).when(scopeGuard).requireOrg(organizationId);

        assertThatThrownBy(() -> testService.view(organizationId, branchId, testId))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization not found");
    }

    @Test
    void viewUnknownBranchIsRejected() {
        doThrow(new NotFoundException("Branch not found")).when(scopeGuard).requireBranch(organizationId, branchId);

        assertThatThrownBy(() -> testService.view(organizationId, branchId, testId))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Branch not found");
    }

    @Test
    void viewUnknownTestIsRejected() {
        when(testMasterRepository.findById(testId)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> testService.view(organizationId, branchId, testId))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Test not found");
    }

    @Test
    void viewTestFromAnotherScopeIsInaccessible() {
        TestMaster test = existingTest();
        test.setOrganizationId(UUID.randomUUID());
        when(testMasterRepository.findById(testId)).thenReturn(Optional.of(test));

        assertThatThrownBy(() -> testService.view(organizationId, branchId, testId))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Test not accessible");
    }

    @Test
    void viewSucceeds() {
        when(testMasterRepository.findById(testId)).thenReturn(Optional.of(existingTest()));

        TestResponse response = testService.view(organizationId, branchId, testId);

        assertThat(response.id()).isEqualTo(testId);
        assertThat(response.testCode()).isEqualTo("LFT001");
    }

    // --- update (API-008) ---

    private UpdateTestRequest updateRequest() {
        return new UpdateTestRequest(
                departmentId, "LFT001", "Liver Function Test Updated", BigDecimal.valueOf(650), null, null, null,
                null, null, null, null, null, null);
    }

    @Test
    void updateMissingTestCodeIsRejected() {
        var request = new UpdateTestRequest(
                departmentId, null, "Liver Function Test", null, null, null, null, null, null, null, null, null,
                null);

        assertThatThrownBy(() -> testService.update(organizationId, branchId, testId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("testCode is required");
        verifyNoInteractions(testMasterRepository);
    }

    @Test
    void updateMissingTestNameIsRejected() {
        var request = new UpdateTestRequest(
                departmentId, "LFT001", null, null, null, null, null, null, null, null, null, null, null);

        assertThatThrownBy(() -> testService.update(organizationId, branchId, testId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("testName is required");
        verifyNoInteractions(testMasterRepository);
    }

    @Test
    void updateUnknownTestIsRejected() {
        when(testMasterRepository.findByIdAndOrganizationIdAndBranchId(testId, organizationId, branchId))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> testService.update(organizationId, branchId, testId, updateRequest()))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Test not found");
    }

    @Test
    void updateUnknownDepartmentIsRejected() {
        when(testMasterRepository.findByIdAndOrganizationIdAndBranchId(testId, organizationId, branchId))
                .thenReturn(Optional.of(existingTest()));
        stubDepartmentExists(false);

        assertThatThrownBy(() -> testService.update(organizationId, branchId, testId, updateRequest()))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Department not found");
    }

    @Test
    void updateDuplicateTestNameIsRejected() {
        when(testMasterRepository.findByIdAndOrganizationIdAndBranchId(testId, organizationId, branchId))
                .thenReturn(Optional.of(existingTest()));
        stubDepartmentExists(true);
        when(testMasterRepository.existsByOrganizationIdAndBranchIdAndTestNameAndIdNot(
                        organizationId, branchId, "Liver Function Test Updated", testId))
                .thenReturn(true);

        assertThatThrownBy(() -> testService.update(organizationId, branchId, testId, updateRequest()))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate test name");
    }

    @Test
    void updateDuplicateTestCodeIsRejected() {
        when(testMasterRepository.findByIdAndOrganizationIdAndBranchId(testId, organizationId, branchId))
                .thenReturn(Optional.of(existingTest()));
        stubDepartmentExists(true);
        when(testMasterRepository.existsByOrganizationIdAndBranchIdAndTestCodeAndIdNot(
                        organizationId, branchId, "LFT001", testId))
                .thenReturn(true);

        assertThatThrownBy(() -> testService.update(organizationId, branchId, testId, updateRequest()))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate test code");
    }

    @Test
    void updateSucceeds() {
        when(testMasterRepository.findByIdAndOrganizationIdAndBranchId(testId, organizationId, branchId))
                .thenReturn(Optional.of(existingTest()));
        stubDepartmentExists(true);
        when(testMasterRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        TestUpdateResponse response = testService.update(organizationId, branchId, testId, updateRequest());

        assertThat(response.testName()).isEqualTo("Liver Function Test Updated");
        assertThat(response.sellingPrice()).isEqualByComparingTo(BigDecimal.valueOf(650));
        assertThat(response.isActive()).isTrue();
    }

    // --- updateStatus (API-009) ---

    @Test
    void statusMissingIsActiveIsRejected() {
        var request = new TestStatusRequest(null);

        assertThatThrownBy(() -> testService.updateStatus(organizationId, branchId, testId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("Invalid status value");
        verifyNoInteractions(testMasterRepository);
    }

    @Test
    void statusUnknownTestIsRejected() {
        when(testMasterRepository.findByIdAndOrganizationIdAndBranchId(testId, organizationId, branchId))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> testService.updateStatus(organizationId, branchId, testId, new TestStatusRequest(false)))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Test not found");
    }

    @Test
    void statusSucceeds() {
        when(testMasterRepository.findByIdAndOrganizationIdAndBranchId(testId, organizationId, branchId))
                .thenReturn(Optional.of(existingTest()));
        when(testMasterRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

        TestStatusResponse response = testService.updateStatus(organizationId, branchId, testId, new TestStatusRequest(false));

        assertThat(response.id()).isEqualTo(testId);
        assertThat(response.isActive()).isFalse();
    }
}
