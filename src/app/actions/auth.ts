"use server";

import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { headers } from "next/headers";
import { createClient } from "@/lib/supabase/server";
import { sendWelcomeEmail } from "@/lib/resend";

async function origin() {
  const h = await headers();
  return (
    process.env.NEXT_PUBLIC_SITE_URL ||
    `https://${h.get("host") ?? "brightfuture.best"}`
  );
}

export type AuthState = { error?: string; message?: string };

export async function signup(
  _prev: AuthState,
  formData: FormData,
): Promise<AuthState> {
  const fullName = String(formData.get("full_name") ?? "").trim();
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");

  if (!fullName || !email || password.length < 6) {
    return { error: "Please fill all fields (password min 6 characters)." };
  }

  const supabase = await createClient();
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: { full_name: fullName },
      emailRedirectTo: `${await origin()}/auth/callback`,
    },
  });

  if (error) return { error: error.message };

  // Friendly branded confirmation via Resend (Supabase also sends the verify link).
  await sendWelcomeEmail(email, fullName);

  if (data.session) {
    revalidatePath("/", "layout");
    redirect("/dashboard");
  }

  return {
    message:
      "Account created. Check your email to confirm your address, then sign in.",
  };
}

export async function login(
  _prev: AuthState,
  formData: FormData,
): Promise<AuthState> {
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");
  const redirectTo = String(formData.get("redirect") ?? "/dashboard");

  const supabase = await createClient();
  const { error } = await supabase.auth.signInWithPassword({ email, password });

  if (error) return { error: error.message };

  revalidatePath("/", "layout");
  redirect(redirectTo || "/dashboard");
}

export async function logout() {
  const supabase = await createClient();
  await supabase.auth.signOut();
  revalidatePath("/", "layout");
  redirect("/");
}
