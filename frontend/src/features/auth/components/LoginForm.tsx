'use client'

import { zodResolver } from '@hookform/resolvers/zod'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { useForm } from 'react-hook-form'
import { toast } from 'sonner'
import { ApiError } from '@/api/types/api-response'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { useLogin } from '@/features/auth/hooks/use-login'
import { loginSchema, type LoginFormValues } from '@/features/auth/schemas/login-schema'

export function LoginForm() {
  const router = useRouter()
  const login = useLogin()
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
  })

  function onSubmit(values: LoginFormValues) {
    login.mutate(values, {
      onSuccess: () => router.replace('/'),
      onError: (error) => {
        const message = error instanceof ApiError ? error.message : 'Something went wrong. Please try again.'
        toast.error(message)
      },
    })
  }

  return (
    <Card className="w-full max-w-sm">
      <CardHeader>
        <CardTitle>Sign in to X46 LIMS</CardTitle>
        <CardDescription>Enter your username and password.</CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} noValidate className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <Label htmlFor="username">Username</Label>
            <Input id="username" autoComplete="username" {...register('username')} />
            {errors.username && <p className="text-sm text-destructive">{errors.username.message}</p>}
          </div>

          <div className="flex flex-col gap-2">
            <Label htmlFor="password">Password</Label>
            <Input id="password" type="password" autoComplete="current-password" {...register('password')} />
            {errors.password && <p className="text-sm text-destructive">{errors.password.message}</p>}
          </div>

          <Button type="submit" disabled={login.isPending} className="mt-2">
            {login.isPending ? 'Signing in...' : 'Sign in'}
          </Button>
        </form>

        <p className="mt-4 text-center text-sm text-muted-foreground">
          X46 staff?{' '}
          <Link href="/admin/login" className="underline underline-offset-4">
            Administrator sign in
          </Link>
        </p>
      </CardContent>
    </Card>
  )
}
