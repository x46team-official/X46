import { httpClient, unwrap } from '@/api/client/http-client'
import type { ApiResponse } from '@/api/types/api-response'

/**
 * Matches com.x46.backend.security.LoginRequest. organizationCode/branchCode
 * are omitted here — the frontend always uses the single-field login (V44
 * made usernames globally unique), but the backend still accepts them for
 * callers that pass them.
 */
export interface LoginRequest {
  username: string
  password: string
}

/** Matches com.x46.backend.security.LoginResponse exactly. `roles` is role IDs, `roleCodes` is role codes (e.g. "PLATFORM_ADMIN"). */
export interface LoginResponse {
  token: string
  expiresAt: string
  userId: string
  organizationId: string
  branchId: string
  roles: string[]
  roleCodes: string[]
}

export function login(request: LoginRequest): Promise<LoginResponse> {
  return unwrap(httpClient.post<ApiResponse<LoginResponse>>('/api/auth/login', request))
}
