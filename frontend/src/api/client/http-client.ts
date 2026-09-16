import axios, { type AxiosError } from 'axios'
import { ApiError, type ApiResponse } from '@/api/types/api-response'
import { useAuthStore } from '@/store/auth-store'

export const httpClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_BASE_URL,
})

httpClient.interceptors.request.use((config) => {
  const token = useAuthStore.getState().session?.token
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

httpClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError<ApiResponse<unknown>>) => {
    if (error.response?.status === 401) {
      useAuthStore.getState().clearSession()
    }

    const message = error.response?.data && !error.response.data.success
      ? error.response.data.error
      : 'Unable to reach the server. Check your connection and try again.'

    return Promise.reject(new ApiError(error.response?.status ?? 0, message))
  },
)

/** Unwraps the `data` field from a successful ApiResponse envelope. */
export async function unwrap<T>(promise: Promise<{ data: ApiResponse<T> }>): Promise<T> {
  const response = await promise
  if (!response.data.success) {
    throw new ApiError(0, response.data.error)
  }
  return response.data.data
}
