'use client'

import { zodResolver } from '@hookform/resolvers/zod'
import Link from 'next/link'
import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { toast } from 'sonner'
import { ApiError } from '@/api/types/api-response'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { adminSchema, type AdminFormValues } from '@/features/organizations/schemas/admin-schema'
import { branchSchema, type BranchFormValues } from '@/features/organizations/schemas/branch-schema'
import {
  organizationSchema,
  type OrganizationFormValues,
} from '@/features/organizations/schemas/organization-schema'
import { useBootstrapAdmin } from '@/features/organizations/hooks/use-bootstrap-admin'
import { useCreateBranch } from '@/features/organizations/hooks/use-create-branch'
import { useCreateOrganization } from '@/features/organizations/hooks/use-create-organization'

type WizardState =
  | { step: 1 }
  | { step: 2; organizationId: string; organizationCode: string }
  | { step: 3; organizationId: string; organizationCode: string; branchId: string; branchCode: string }
  | {
      step: 'done'
      organizationCode: string
      branchCode: string
      username: string
    }

function errorMessage(error: unknown): string {
  return error instanceof ApiError ? error.message : 'Something went wrong. Please try again.'
}

function OrganizationStep({ onNext }: { onNext: (organizationId: string, organizationCode: string) => void }) {
  const createOrganization = useCreateOrganization()
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<OrganizationFormValues>({ resolver: zodResolver(organizationSchema) })

  function onSubmit(values: OrganizationFormValues) {
    createOrganization.mutate(values, {
      onSuccess: (data) => onNext(data.id, data.organizationCode),
      onError: (error) => toast.error(errorMessage(error)),
    })
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate className="flex flex-col gap-4">
      <div className="flex flex-col gap-2">
        <Label htmlFor="organizationName">Organization name</Label>
        <Input id="organizationName" {...register('organizationName')} />
        {errors.organizationName && <p className="text-sm text-destructive">{errors.organizationName.message}</p>}
      </div>
      <div className="flex flex-col gap-2">
        <Label htmlFor="organizationCode">Organization code</Label>
        <Input id="organizationCode" {...register('organizationCode')} />
        {errors.organizationCode && <p className="text-sm text-destructive">{errors.organizationCode.message}</p>}
      </div>
      <Button type="submit" disabled={createOrganization.isPending} className="mt-2">
        {createOrganization.isPending ? 'Creating organization...' : 'Next: create branch'}
      </Button>
    </form>
  )
}

function BranchStep({
  organizationId,
  onNext,
}: {
  organizationId: string
  onNext: (branchId: string, branchCode: string) => void
}) {
  const createBranch = useCreateBranch()
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<BranchFormValues>({ resolver: zodResolver(branchSchema) })

  function onSubmit(values: BranchFormValues) {
    createBranch.mutate(
      { organizationId, request: values },
      {
        onSuccess: (data) => onNext(data.id, data.branchCode),
        onError: (error) => toast.error(errorMessage(error)),
      },
    )
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate className="flex flex-col gap-4">
      <div className="flex flex-col gap-2">
        <Label htmlFor="branchName">Branch name</Label>
        <Input id="branchName" {...register('branchName')} />
        {errors.branchName && <p className="text-sm text-destructive">{errors.branchName.message}</p>}
      </div>
      <div className="flex flex-col gap-2">
        <Label htmlFor="branchCode">Branch code</Label>
        <Input id="branchCode" {...register('branchCode')} />
        {errors.branchCode && <p className="text-sm text-destructive">{errors.branchCode.message}</p>}
      </div>
      <Button type="submit" disabled={createBranch.isPending} className="mt-2">
        {createBranch.isPending ? 'Creating branch...' : 'Next: create admin login'}
      </Button>
    </form>
  )
}

function AdminStep({
  organizationId,
  branchId,
  onNext,
}: {
  organizationId: string
  branchId: string
  onNext: (username: string) => void
}) {
  const bootstrapAdmin = useBootstrapAdmin()
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<AdminFormValues>({ resolver: zodResolver(adminSchema) })

  function onSubmit(values: AdminFormValues) {
    bootstrapAdmin.mutate(
      {
        organizationId,
        branchId,
        request: { ...values, email: values.email || undefined },
      },
      {
        onSuccess: (data) => onNext(data.username),
        onError: (error) => toast.error(errorMessage(error)),
      },
    )
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)} noValidate className="flex flex-col gap-4">
      <div className="flex flex-col gap-2">
        <Label htmlFor="firstName">First name</Label>
        <Input id="firstName" {...register('firstName')} />
        {errors.firstName && <p className="text-sm text-destructive">{errors.firstName.message}</p>}
      </div>
      <div className="flex flex-col gap-2">
        <Label htmlFor="lastName">Last name</Label>
        <Input id="lastName" {...register('lastName')} />
      </div>
      <div className="flex flex-col gap-2">
        <Label htmlFor="email">Email</Label>
        <Input id="email" type="email" {...register('email')} />
        {errors.email && <p className="text-sm text-destructive">{errors.email.message}</p>}
      </div>
      <div className="flex flex-col gap-2">
        <Label htmlFor="username">Username</Label>
        <Input id="username" autoComplete="username" {...register('username')} />
        {errors.username && <p className="text-sm text-destructive">{errors.username.message}</p>}
      </div>
      <div className="flex flex-col gap-2">
        <Label htmlFor="password">Password</Label>
        <Input id="password" type="password" autoComplete="new-password" {...register('password')} />
        {errors.password && <p className="text-sm text-destructive">{errors.password.message}</p>}
      </div>
      <Button type="submit" disabled={bootstrapAdmin.isPending} className="mt-2">
        {bootstrapAdmin.isPending ? 'Creating admin login...' : 'Finish'}
      </Button>
    </form>
  )
}

export function OrganizationWizard() {
  const [state, setState] = useState<WizardState>({ step: 1 })

  return (
    <Card className="w-full max-w-sm">
      <CardHeader>
        <CardTitle>
          {state.step === 'done' ? 'Organization ready' : `Create organization — step ${state.step} of 3`}
        </CardTitle>
        <CardDescription>
          {state.step === 1 && 'Step 1: the organization itself.'}
          {state.step === 2 && 'Step 2: its first branch.'}
          {state.step === 3 && "Step 3: the branch's first admin login."}
          {state.step === 'done' && 'The organization, branch, and first admin login all exist now.'}
        </CardDescription>
      </CardHeader>
      <CardContent>
        {state.step === 1 && (
          <OrganizationStep
            onNext={(organizationId, organizationCode) => setState({ step: 2, organizationId, organizationCode })}
          />
        )}
        {state.step === 2 && (
          <BranchStep
            organizationId={state.organizationId}
            onNext={(branchId, branchCode) =>
              setState({
                step: 3,
                organizationId: state.organizationId,
                organizationCode: state.organizationCode,
                branchId,
                branchCode,
              })
            }
          />
        )}
        {state.step === 3 && (
          <AdminStep
            organizationId={state.organizationId}
            branchId={state.branchId}
            onNext={(username) =>
              setState({
                step: 'done',
                organizationCode: state.organizationCode,
                branchCode: state.branchCode,
                username,
              })
            }
          />
        )}
        {state.step === 'done' && (
          <div className="flex flex-col gap-3 text-sm">
            <p>
              <span className="text-muted-foreground">Organization code:</span> {state.organizationCode}
            </p>
            <p>
              <span className="text-muted-foreground">Branch code:</span> {state.branchCode}
            </p>
            <p>
              <span className="text-muted-foreground">Admin username:</span> {state.username}
            </p>
            <Button asChild className="mt-2">
              <Link href="/organizations">Go to monitoring dashboard</Link>
            </Button>
          </div>
        )}
      </CardContent>
    </Card>
  )
}
