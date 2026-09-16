import type { Metadata } from 'next'
import { LoginForm } from '@/features/auth/components/LoginForm'

export const metadata: Metadata = {
  title: 'Sign in — X46 LIMS',
}

export default function LoginPage() {
  return (
    <div className="flex min-h-svh flex-1 items-center justify-center bg-muted/30 p-4">
      <LoginForm />
    </div>
  )
}
