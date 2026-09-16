'use client'

import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { useAuthStore } from '@/store/auth-store'

const NAV_ITEMS = [
  { href: '/organizations', label: 'Dashboard' },
  { href: '/organizations/new', label: 'Create organization' },
]

export function PlatformAdminSidebar() {
  const pathname = usePathname()
  const router = useRouter()
  const clearSession = useAuthStore((state) => state.clearSession)

  function handleLogout() {
    clearSession()
    router.replace('/admin/login')
  }

  return (
    <aside className="flex h-svh w-56 shrink-0 flex-col justify-between border-r bg-muted/30 p-4">
      <div className="flex flex-col gap-1">
        <div className="px-2 pb-4">
          <p className="text-sm font-semibold">X46 Admin</p>
          <p className="text-xs text-muted-foreground">Platform monitoring</p>
        </div>
        <nav className="flex flex-col gap-1">
          {NAV_ITEMS.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'rounded-md px-2 py-1.5 text-sm transition-colors hover:bg-muted hover:text-foreground',
                pathname === item.href ? 'bg-muted font-medium text-foreground' : 'text-muted-foreground',
              )}
            >
              {item.label}
            </Link>
          ))}
        </nav>
      </div>

      <Button variant="outline" onClick={handleLogout}>
        Log out
      </Button>
    </aside>
  )
}
