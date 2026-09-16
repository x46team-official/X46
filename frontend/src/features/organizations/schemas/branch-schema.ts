import { z } from 'zod'

export const branchSchema = z.object({
  branchCode: z.string().min(1, 'Branch code is required'),
  branchName: z.string().min(1, 'Branch name is required'),
})

export type BranchFormValues = z.infer<typeof branchSchema>
