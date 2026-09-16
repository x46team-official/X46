import { OrganizationUsers } from '@/features/organizations/components/OrganizationUsers'

export default async function OrganizationUsersPage({
  params,
}: {
  params: Promise<{ organizationId: string }>
}) {
  const { organizationId } = await params
  return <OrganizationUsers organizationId={organizationId} />
}
