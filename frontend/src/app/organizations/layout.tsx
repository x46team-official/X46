'use client'

import { PlatformAdminGuard } from '@/features/auth/components/PlatformAdminGuard'
import { PlatformAdminSidebar } from '@/features/organizations/components/PlatformAdminSidebar'

export default function OrganizationsLayout({ children }: { children: React.ReactNode }) {
  return (
    <PlatformAdminGuard>
      <div className="flex min-h-svh">
        <PlatformAdminSidebar />
        <main className="flex-1 overflow-y-auto">{children}</main>
      </div>
    </PlatformAdminGuard>
  )
}
