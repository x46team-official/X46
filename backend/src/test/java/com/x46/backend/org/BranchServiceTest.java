package com.x46.backend.org;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.NotFoundException;
import com.x46.backend.common.ScopeGuard;
import com.x46.backend.common.ValidationException;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class BranchServiceTest {

    @Mock
    private BranchRepository branchRepository;

    @Mock
    private ScopeGuard scopeGuard;

    private BranchService branchService;

    private final UUID organizationId = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        branchService = new BranchService(branchRepository, scopeGuard);
    }

    @Test
    void missingBranchCodeIsRejected() {
        var request = new CreateBranchRequest(null, "Pune Main Branch", null);

        assertThatThrownBy(() -> branchService.create(organizationId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("branchCode is required");
        verifyNoInteractions(scopeGuard, branchRepository);
    }

    @Test
    void missingBranchNameIsRejected() {
        var request = new CreateBranchRequest("PUNE-01", null, null);

        assertThatThrownBy(() -> branchService.create(organizationId, request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("branchName is required");
        verifyNoInteractions(scopeGuard, branchRepository);
    }

    @Test
    void unknownOrganizationIsRejected() {
        doThrow(new NotFoundException("Organization not found")).when(scopeGuard).requireOrg(organizationId);
        var request = new CreateBranchRequest("PUNE-01", "Pune Main Branch", null);

        assertThatThrownBy(() -> branchService.create(organizationId, request))
                .isInstanceOf(NotFoundException.class)
                .hasMessage("Organization not found");
    }

    @Test
    void duplicateBranchCodeIsRejected() {
        when(branchRepository.existsByOrganizationIdAndBranchCode(organizationId, "PUNE-01")).thenReturn(true);
        var request = new CreateBranchRequest("PUNE-01", "Pune Main Branch", null);

        assertThatThrownBy(() -> branchService.create(organizationId, request))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate branch code");
    }

    @Test
    void unexpectedRepositoryFailurePropagatesForTheGlobalHandlerToMapTo500() {
        when(branchRepository.existsByOrganizationIdAndBranchCode(organizationId, "PUNE-01")).thenReturn(false);
        when(branchRepository.save(any())).thenThrow(new RuntimeException("db down"));
        var request = new CreateBranchRequest("PUNE-01", "Pune Main Branch", null);

        assertThatThrownBy(() -> branchService.create(organizationId, request))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("db down");
    }

    @Test
    void validRequestCreatesBranchDefaultingIsActiveToTrue() {
        when(branchRepository.existsByOrganizationIdAndBranchCode(organizationId, "PUNE-01")).thenReturn(false);
        when(branchRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        var request = new CreateBranchRequest("PUNE-01", "Pune Main Branch", null);

        BranchResponse response = branchService.create(organizationId, request);

        assertThat(response.organizationId()).isEqualTo(organizationId);
        assertThat(response.branchCode()).isEqualTo("PUNE-01");
        assertThat(response.branchName()).isEqualTo("Pune Main Branch");
        assertThat(response.isActive()).isTrue();
    }

    @Test
    void explicitIsActiveFalseIsRespected() {
        when(branchRepository.existsByOrganizationIdAndBranchCode(organizationId, "PUNE-02")).thenReturn(false);
        when(branchRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        var request = new CreateBranchRequest("PUNE-02", "Pune Second Branch", false);

        BranchResponse response = branchService.create(organizationId, request);

        assertThat(response.isActive()).isFalse();
    }
}
