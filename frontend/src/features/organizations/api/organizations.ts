import { httpClient, unwrap } from '@/api/client/http-client'
import type { ApiResponse } from '@/api/types/api-response'

/** Matches com.x46.backend.org.dto.CreateOrganizationRequest / OrganizationResponse (API-001). */
export interface CreateOrganizationRequest {
  organizationName: string
  organizationCode: string
}

export interface OrganizationResponse {
  id: string
  organizationCode: string
  organizationName: string
  isActive: boolean
}

/** Matches com.x46.backend.org.dto.CreateBranchRequest / BranchResponse (API-002). */
export interface CreateBranchRequest {
  branchCode: string
  branchName: string
}

export interface BranchResponse {
  id: string
  organizationId: string
  branchCode: string
  branchName: string
  isActive: boolean
}

/** Matches com.x46.backend.identity.dto.BootstrapAdminRequest / BootstrapAdminResponse (Chunk 1.7). */
export interface BootstrapAdminRequest {
  username: string
  email?: string
  password: string
  firstName: string
  lastName?: string
}

export interface BootstrapAdminResponse {
  organizationId: string
  branchId: string
  roleId: string
  roleCode: string
  userId: string
  username: string
}

/** Matches com.x46.backend.org.dto.OrganizationSummaryResponse (Chunk 1.6). */
export interface OrganizationSummaryResponse {
  id: string
  organizationCode: string
  organizationName: string
  isActive: boolean
  branchCount: number
  userCount: number
}

export function createOrganization(request: CreateOrganizationRequest): Promise<OrganizationResponse> {
  return unwrap(httpClient.post<ApiResponse<OrganizationResponse>>('/api/organizations', request))
}

export function createBranch(organizationId: string, request: CreateBranchRequest): Promise<BranchResponse> {
  return unwrap(
    httpClient.post<ApiResponse<BranchResponse>>(`/api/organizations/${organizationId}/branches`, request),
  )
}

export function bootstrapAdmin(
  organizationId: string,
  branchId: string,
  request: BootstrapAdminRequest,
): Promise<BootstrapAdminResponse> {
  return unwrap(
    httpClient.post<ApiResponse<BootstrapAdminResponse>>(
      `/api/organizations/${organizationId}/branches/${branchId}/bootstrap-admin`,
      request,
    ),
  )
}

export function listOrganizations(): Promise<OrganizationSummaryResponse[]> {
  return unwrap(httpClient.get<ApiResponse<OrganizationSummaryResponse[]>>('/api/organizations'))
}

/** Matches com.x46.backend.identity.dto.OrganizationUserResponse (Chunk 1.8). */
export interface OrganizationUserResponse {
  id: string
  branchId: string
  branchCode: string
  username: string
  email: string | null
  firstName: string
  lastName: string | null
  isActive: boolean
}

export function listOrganizationUsers(organizationId: string): Promise<OrganizationUserResponse[]> {
  return unwrap(
    httpClient.get<ApiResponse<OrganizationUserResponse[]>>(`/api/organizations/${organizationId}/users`),
  )
}
