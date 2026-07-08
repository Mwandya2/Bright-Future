import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import type { Profile } from "@/lib/types";

/**
 * Loads the authenticated user and their profile. Redirects to /login when
 * signed out. Optionally requires the admin role.
 */
export async function requireProfile(opts?: { admin?: boolean }): Promise<{
  user: { id: string; email?: string };
  profile: Profile;
}> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect("/login");

  const { data: profile } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", user.id)
    .single();

  const resolved: Profile =
    (profile as Profile) ??
    ({
      id: user.id,
      full_name: (user.user_metadata?.full_name as string) ?? null,
      email: user.email ?? null,
      phone: null,
      role: "student",
      avatar_url: null,
      created_at: new Date().toISOString(),
    } satisfies Profile);

  if (opts?.admin && resolved.role !== "admin") redirect("/dashboard");

  return { user: { id: user.id, email: user.email }, profile: resolved };
}
