import { useEffect, useState } from 'react'
import { create } from 'zustand'
import { createJSONStorage, persist, type StateStorage } from 'zustand/middleware'

export interface AuthSession {
  token: string
  expiresAt: string
  userId: string
  organizationId: string
  branchId: string
  roles: string[]
  roleCodes: string[]
}

interface AuthState {
  session: AuthSession | null
  setSession: (session: AuthSession) => void
  clearSession: () => void
}

/**
 * zustand's default persist storage reads `window.localStorage` eagerly,
 * which throws during Next's server-side prerendering (`window` doesn't
 * exist there, even for 'use client' components). This adapter defers the
 * `window` check to each call and no-ops on the server.
 */
const ssrSafeStorage: StateStorage = {
  getItem: (name) => (typeof window !== 'undefined' ? window.localStorage.getItem(name) : null),
  setItem: (name, value) => {
    if (typeof window !== 'undefined') window.localStorage.setItem(name, value)
  },
  removeItem: (name) => {
    if (typeof window !== 'undefined') window.localStorage.removeItem(name)
  },
}

/** skipHydration: rehydration is triggered below, guarded to the browser only. */
export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      session: null,
      setSession: (session) => set({ session }),
      clearSession: () => set({ session: null }),
    }),
    { name: 'x46-auth', storage: createJSONStorage(() => ssrSafeStorage), skipHydration: true },
  ),
)

if (typeof window !== 'undefined') {
  useAuthStore.persist.rehydrate()
}

/** True once localStorage has been read. Guards against a flash of "logged out" before hydration finishes. */
export function useHasHydrated(): boolean {
  const [hydrated, setHydrated] = useState(() => useAuthStore.persist.hasHydrated())

  useEffect(() => {
    if (hydrated) return
    return useAuthStore.persist.onFinishHydration(() => setHydrated(true))
  }, [hydrated])

  return hydrated
}

export function isSessionExpired(session: AuthSession): boolean {
  return new Date(session.expiresAt).getTime() <= Date.now()
}
