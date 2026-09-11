package com.x46.backend.org;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.ValidationException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class OrganizationServiceTest {

    @Mock
    private OrganizationRepository organizationRepository;

    private OrganizationService organizationService;

    @BeforeEach
    void setUp() {
        organizationService = new OrganizationService(organizationRepository);
    }

    @Test
    void missingOrganizationNameIsRejected() {
        var request = new CreateOrganizationRequest(null, "ORG001", null);

        assertThatThrownBy(() -> organizationService.create(request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("organizationName is required");
    }

    @Test
    void missingOrganizationCodeIsRejected() {
        var request = new CreateOrganizationRequest("X46 Diagnostics", null, null);

        assertThatThrownBy(() -> organizationService.create(request))
                .isInstanceOf(ValidationException.class)
                .hasMessage("organizationCode is required");
    }

    @Test
    void duplicateOrganizationCodeIsRejected() {
        when(organizationRepository.existsByOrganizationCode("ORG001")).thenReturn(true);
        var request = new CreateOrganizationRequest("X46 Diagnostics", "ORG001", null);

        assertThatThrownBy(() -> organizationService.create(request))
                .isInstanceOf(ConflictException.class)
                .hasMessage("Duplicate organization code");
    }

    @Test
    void unexpectedRepositoryFailurePropagatesForTheGlobalHandlerToMapTo500() {
        when(organizationRepository.existsByOrganizationCode("ORG001")).thenReturn(false);
        when(organizationRepository.save(any())).thenThrow(new RuntimeException("db down"));
        var request = new CreateOrganizationRequest("X46 Diagnostics", "ORG001", null);

        assertThatThrownBy(() -> organizationService.create(request))
                .isInstanceOf(RuntimeException.class)
                .hasMessage("db down");
    }

    @Test
    void validRequestCreatesOrganizationDefaultingIsActiveToTrue() {
        when(organizationRepository.existsByOrganizationCode("ORG001")).thenReturn(false);
        when(organizationRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        var request = new CreateOrganizationRequest("X46 Diagnostics", "ORG001", null);

        OrganizationResponse response = organizationService.create(request);

        assertThat(response.organizationCode()).isEqualTo("ORG001");
        assertThat(response.organizationName()).isEqualTo("X46 Diagnostics");
        assertThat(response.isActive()).isTrue();
    }

    @Test
    void explicitIsActiveFalseIsRespected() {
        when(organizationRepository.existsByOrganizationCode("ORG002")).thenReturn(false);
        when(organizationRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));
        var request = new CreateOrganizationRequest("X46 Diagnostics", "ORG002", false);

        OrganizationResponse response = organizationService.create(request);

        assertThat(response.isActive()).isFalse();
    }
}
