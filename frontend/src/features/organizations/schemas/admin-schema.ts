import { z } from 'zod'

export const adminSchema = z.object({
  username: z.string().min(1, 'Username is required'),
  password: z.string().min(1, 'Password is required'),
  firstName: z.string().min(1, 'First name is required'),
  lastName: z.string().optional(),
  email: z.string().email('Enter a valid email').optional().or(z.literal('')),
})

export type AdminFormValues = z.infer<typeof adminSchema>
