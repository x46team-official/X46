import { useMutation } from '@tanstack/react-query'
import { bootstrapAdmin, type BootstrapAdminRequest } from '@/features/organizations/api/organizations'

export function useBootstrapAdmin() {
  return useMutation({
    mutationFn: ({
      organizationId,
      branchId,
      request,
    }: {
      organizationId: string
      branchId: string
      request: BootstrapAdminRequest
    }) => bootstrapAdmin(organizationId, branchId, request),
  })
}
