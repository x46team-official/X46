import type { Metadata } from 'next'
import { AdminLoginForm } from '@/features/auth/components/AdminLoginForm'

export const metadata: Metadata = {
  title: 'Administrator sign in — X46 LIMS',
}

export default function AdminLoginPage() {
  return (
    <div className="flex min-h-svh flex-1 items-center justify-center bg-muted/30 p-4">
      <AdminLoginForm />
    </div>
  )
}
