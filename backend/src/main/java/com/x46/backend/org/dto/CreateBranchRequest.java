package com.x46.backend.org.dto;

public record CreateBranchRequest(String branchCode, String branchName, Boolean isActive) {
}
