package com.x46.backend.org;

import com.x46.backend.common.ConflictException;
import com.x46.backend.common.ScopeGuard;
import com.x46.backend.common.ValidationException;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.springframework.stereotype.Service;

@Service
public class BranchService {

    private final BranchRepository branchRepository;
    private final ScopeGuard scopeGuard;

    BranchService(BranchRepository branchRepository, ScopeGuard scopeGuard) {
        this.branchRepository = branchRepository;
        this.scopeGuard = scopeGuard;
    }

    public BranchResponse create(UUID organizationId, CreateBranchRequest request) {
        if (isBlank(request.branchCode())) {
            throw new ValidationException("branchCode is required");
        }
        if (isBlank(request.branchName())) {
            throw new ValidationException("branchName is required");
        }
        scopeGuard.requireOrg(organizationId);
        if (branchRepository.existsByOrganizationIdAndBranchCode(organizationId, request.branchCode())) {
            throw new ConflictException("Duplicate branch code");
        }

        OffsetDateTime now = OffsetDateTime.now();
        Branch branch = new Branch();
        branch.setOrganizationId(organizationId);
        branch.setBranchCode(request.branchCode());
        branch.setBranchName(request.branchName());
        branch.setActive(request.isActive() == null || request.isActive());
        branch.setCreatedAt(now);
        branch.setUpdatedAt(now);

        Branch saved = branchRepository.save(branch);
        return new BranchResponse(
                saved.getId(), saved.getOrganizationId(), saved.getBranchCode(), saved.getBranchName(),
                saved.isActive());
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
