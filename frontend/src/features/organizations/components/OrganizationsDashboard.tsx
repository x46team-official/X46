'use client'

import Link from 'next/link'
import { ApiError } from '@/api/types/api-response'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { useOrganizations } from '@/features/organizations/hooks/use-organizations'

export function OrganizationsDashboard() {
  const { data: organizations, isLoading, error } = useOrganizations()

  const totalOrganizations = organizations?.length ?? 0
  const totalBranches = organizations?.reduce((sum, org) => sum + org.branchCount, 0) ?? 0
  const totalUsers = organizations?.reduce((sum, org) => sum + org.userCount, 0) ?? 0

  return (
    <div className="mx-auto flex w-full max-w-4xl flex-col gap-6 p-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Platform monitoring</h1>
        <Button asChild>
          <Link href="/organizations/new">Create organization</Link>
        </Button>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <Card>
          <CardHeader>
            <CardDescription>Organizations</CardDescription>
            <CardTitle className="text-3xl">{totalOrganizations}</CardTitle>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader>
            <CardDescription>Branches</CardDescription>
            <CardTitle className="text-3xl">{totalBranches}</CardTitle>
          </CardHeader>
        </Card>
        <Card>
          <CardHeader>
            <CardDescription>Users</CardDescription>
            <CardTitle className="text-3xl">{totalUsers}</CardTitle>
          </CardHeader>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Organizations</CardTitle>
        </CardHeader>
        <CardContent>
          {isLoading && <p className="text-sm text-muted-foreground">Loading...</p>}
          {error && (
            <p className="text-sm text-destructive">
              {error instanceof ApiError ? error.message : 'Failed to load organizations.'}
            </p>
          )}
          {organizations && organizations.length === 0 && (
            <p className="text-sm text-muted-foreground">No organizations yet.</p>
          )}
          {organizations && organizations.length > 0 && (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Code</TableHead>
                  <TableHead>Name</TableHead>
                  <TableHead>Active</TableHead>
                  <TableHead>Branches</TableHead>
                  <TableHead>Users</TableHead>
                  <TableHead></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {organizations.map((org) => (
                  <TableRow key={org.id}>
                    <TableCell>{org.organizationCode}</TableCell>
                    <TableCell>{org.organizationName}</TableCell>
                    <TableCell>{org.isActive ? 'Yes' : 'No'}</TableCell>
                    <TableCell>{org.branchCount}</TableCell>
                    <TableCell>{org.userCount}</TableCell>
                    <TableCell>
                      <Link href={`/organizations/${org.id}/users`} className="text-sm underline underline-offset-4">
                        View users
                      </Link>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
