import { useMutation } from '@tanstack/react-query'
import { createOrganization } from '@/features/organizations/api/organizations'

export function useCreateOrganization() {
  return useMutation({ mutationFn: createOrganization })
}
