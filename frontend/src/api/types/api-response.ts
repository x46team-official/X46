/** Mirrors com.x46.backend.common.ApiResponse<T> exactly — every backend endpoint uses this envelope. */
export interface ApiSuccessResponse<T> {
  success: true
  message?: string
  data: T
}

export interface ApiErrorResponse {
  success: false
  error: string
}

export type ApiResponse<T> = ApiSuccessResponse<T> | ApiErrorResponse

/** Thrown by the http client for any non-2xx response. `message` is the backend's `error` string. */
export class ApiError extends Error {
  status: number

  constructor(status: number, message: string) {
    super(message)
    this.name = 'ApiError'
    this.status = status
  }
}
