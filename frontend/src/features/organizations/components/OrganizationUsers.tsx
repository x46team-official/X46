'use client'

import Link from 'next/link'
import { ApiError } from '@/api/types/api-response'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { useOrganizationUsers } from '@/features/organizations/hooks/use-organization-users'

export function OrganizationUsers({ organizationId }: { organizationId: string }) {
  const { data: users, isLoading, error } = useOrganizationUsers(organizationId)

  return (
    <div className="mx-auto flex w-full max-w-4xl flex-col gap-6 p-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Organization users</h1>
        <Button variant="outline" asChild>
          <Link href="/organizations">Back to dashboard</Link>
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Users{users ? ` (${users.length})` : ''}</CardTitle>
        </CardHeader>
        <CardContent>
          {isLoading && <p className="text-sm text-muted-foreground">Loading...</p>}
          {error && (
            <p className="text-sm text-destructive">
              {error instanceof ApiError ? error.message : 'Failed to load users.'}
            </p>
          )}
          {users && users.length === 0 && <p className="text-sm text-muted-foreground">No users yet.</p>}
          {users && users.length > 0 && (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Username</TableHead>
                  <TableHead>Branch</TableHead>
                  <TableHead>Name</TableHead>
                  <TableHead>Email</TableHead>
                  <TableHead>Active</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {users.map((user) => (
                  <TableRow key={user.id}>
                    <TableCell>{user.username}</TableCell>
                    <TableCell>{user.branchCode}</TableCell>
                    <TableCell>
                      {user.firstName} {user.lastName ?? ''}
                    </TableCell>
                    <TableCell>{user.email ?? '—'}</TableCell>
                    <TableCell>{user.isActive ? 'Yes' : 'No'}</TableCell>
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
