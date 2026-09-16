import type { AuthSession } from '@/store/auth-store'

export function isPlatformAdmin(session: AuthSession | null): boolean {
  return session?.roleCodes.includes('PLATFORM_ADMIN') ?? false
}
