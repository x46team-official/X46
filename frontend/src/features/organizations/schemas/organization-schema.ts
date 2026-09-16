import { z } from 'zod'

export const organizationSchema = z.object({
  organizationName: z.string().min(1, 'Organization name is required'),
  organizationCode: z.string().min(1, 'Organization code is required'),
})

export type OrganizationFormValues = z.infer<typeof organizationSchema>
