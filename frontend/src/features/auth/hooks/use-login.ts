import { useMutation } from '@tanstack/react-query'
import { login } from '@/features/auth/api/login'
import { useAuthStore } from '@/store/auth-store'

export function useLogin() {
  const setSession = useAuthStore((state) => state.setSession)

  return useMutation({
    mutationFn: login,
    onSuccess: (data) => {
      setSession(data)
    },
  })
}
