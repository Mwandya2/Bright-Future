import { redirect } from "next/navigation";
import { cookies } from "next/headers";
import { apiClient, AUTH_COOKIE_NAME } from "@/lib/api-client";
import { isTheAdmin } from "@/lib/admin";
import type { Profile, Role } from "@/lib/types";

interface UserResponse {
  id: string;
  email: string;
  fullName: string | null;
  phone: string | null;
  role: Role;
  avatarUrl: string | null;
  createdAt: string;
}

export async function getOptionalProfile(): Promise<{
  user: { id: string; email?: string };
  profile: Profile;
} | null> {
  try {
    const cookieStore = await cookies();
    const token = cookieStore.get(AUTH_COOKIE_NAME)?.value;
    if (!token) return null;

    const res = await apiClient.get<UserResponse>("/auth/me");
    if (!res.success || !res.data) return null;

    const u = res.data;
    const profile: Profile = {
      id: u.id,
      full_name: u.fullName,
      email: u.email,
      phone: u.phone,
      role: (u.role.toLowerCase() as "student" | "instructor" | "admin"),
      avatar_url: u.avatarUrl,
      created_at: u.createdAt,
    };

    return {
      user: { id: u.id, email: u.email },
      profile,
    };
  } catch {
    return null;
  }
}

/**
 * Loads the authenticated user and their profile from Spring Boot backend.
 * Redirects to /login when signed out. Optionally requires the admin role.
 */
export async function requireProfile(opts?: { admin?: boolean }): Promise<{
  user: { id: string; email?: string };
  profile: Profile;
}> {
  const session = await getOptionalProfile();
  if (!session) {
    redirect("/login");
  }

  if (opts?.admin && !isTheAdmin(session.user.email, session.profile.role)) {
    redirect("/dashboard");
  }

  return session;
}
