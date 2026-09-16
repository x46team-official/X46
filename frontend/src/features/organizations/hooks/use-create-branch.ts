import { useMutation } from '@tanstack/react-query'
import { createBranch, type CreateBranchRequest } from '@/features/organizations/api/organizations'

export function useCreateBranch() {
  return useMutation({
    mutationFn: ({ organizationId, request }: { organizationId: string; request: CreateBranchRequest }) =>
      createBranch(organizationId, request),
  })
}
