'use client'

import { useRouter } from 'next/navigation'
import { useEffect } from 'react'
import { isPlatformAdmin } from '@/features/auth/lib/is-platform-admin'
import { isSessionExpired, useAuthStore, useHasHydrated } from '@/store/auth-store'

/** Redirects away from platform-admin-only pages unless the session is a valid, unexpired PLATFORM_ADMIN login. */
export function PlatformAdminGuard({ children }: { children: React.ReactNode }) {
  const router = useRouter()
  const session = useAuthStore((state) => state.session)
  const hasHydrated = useHasHydrated()

  useEffect(() => {
    if (!hasHydrated) return
    if (!session || isSessionExpired(session)) {
      router.replace('/login')
    } else if (!isPlatformAdmin(session)) {
      router.replace('/')
    }
  }, [hasHydrated, session, router])

  if (!hasHydrated || !session || isSessionExpired(session) || !isPlatformAdmin(session)) {
    return null
  }

  return <>{children}</>
}
