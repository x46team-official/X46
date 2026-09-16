'use client'

import { useRouter } from 'next/navigation'
import { useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { isSessionExpired, useAuthStore, useHasHydrated } from '@/store/auth-store'

export default function DashboardPage() {
  const router = useRouter()
  const session = useAuthStore((state) => state.session)
  const clearSession = useAuthStore((state) => state.clearSession)
  const hasHydrated = useHasHydrated()

  useEffect(() => {
    if (hasHydrated && (!session || isSessionExpired(session))) {
      router.replace('/login')
    }
  }, [hasHydrated, session, router])

  function handleLogout() {
    clearSession()
    router.replace('/login')
  }

  if (!hasHydrated || !session) {
    return null
  }

  return (
    <div className="flex min-h-svh flex-1 flex-col items-center justify-center gap-6 p-4">
      <Card className="w-full max-w-md">
        <CardHeader>
          <CardTitle>Signed in</CardTitle>
          <CardDescription>You&apos;re authenticated against the X46 LIMS API.</CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-2 text-sm">
          <p>
            <span className="text-muted-foreground">User ID:</span> {session.userId}
          </p>
          <p>
            <span className="text-muted-foreground">Organization ID:</span> {session.organizationId}
          </p>
          <p>
            <span className="text-muted-foreground">Branch ID:</span> {session.branchId}
          </p>
          <p>
            <span className="text-muted-foreground">Session expires:</span>{' '}
            {new Date(session.expiresAt).toLocaleString()}
          </p>
          <Button variant="outline" className="mt-4" onClick={handleLogout}>
            Log out
          </Button>
        </CardContent>
      </Card>
    </div>
  )
}
