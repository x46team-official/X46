import { useQuery } from '@tanstack/react-query'
import { listOrganizationUsers } from '@/features/organizations/api/organizations'

export function useOrganizationUsers(organizationId: string) {
  return useQuery({
    queryKey: ['organizations', organizationId, 'users'],
    queryFn: () => listOrganizationUsers(organizationId),
  })
}
