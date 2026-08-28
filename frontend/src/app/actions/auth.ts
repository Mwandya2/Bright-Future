"use server";

import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { cookies } from "next/headers";
import { apiClient, AUTH_COOKIE_NAME } from "@/lib/api-client";
import { sendWelcomeEmail } from "@/lib/resend";
import type { Role } from "@/lib/types";

export type AuthState = { error?: string; message?: string };

interface AuthResult {
  token: string;
  tokenType: string;
  user: {
    id: string;
    email: string;
    fullName: string;
    phone?: string;
    role: Role;
  };
}

export async function signup(
  _prev: AuthState,
  formData: FormData,
): Promise<AuthState> {
  const fullName = String(formData.get("full_name") ?? "").trim();
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");
  const phone = String(formData.get("phone") ?? "").trim() || undefined;

  if (!fullName || !email || password.length < 6) {
    return { error: "Please fill all fields (password min 6 characters)." };
  }

  const res = await apiClient.post<AuthResult>("/auth/signup", {
    fullName,
    email,
    password,
    phone,
  });

  if (!res.success || !res.data) {
    return { error: res.message || "Failed to create account." };
  }

  // Set auth cookie
  const cookieStore = await cookies();
  cookieStore.set(AUTH_COOKIE_NAME, res.data.token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge: 7 * 24 * 60 * 60, // 7 days
  });

  // Branded welcome email
  try {
    await sendWelcomeEmail(email, fullName);
  } catch (err) {
    console.error("Welcome email error:", err);
  }

  revalidatePath("/", "layout");
  redirect("/dashboard");
}

export async function login(
  _prev: AuthState,
  formData: FormData,
): Promise<AuthState> {
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");
  const redirectTo = String(formData.get("redirect") ?? "/dashboard");

  if (!email || !password) {
    return { error: "Email and password are required." };
  }

  const res = await apiClient.post<AuthResult>("/auth/login", {
    email,
    password,
  });

  if (!res.success || !res.data) {
    return { error: res.message || "Invalid email or password." };
  }

  const cookieStore = await cookies();
  cookieStore.set(AUTH_COOKIE_NAME, res.data.token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge: 7 * 24 * 60 * 60,
  });

  revalidatePath("/", "layout");
  redirect(redirectTo || "/dashboard");
}

export async function adminLogin(
  _prev: AuthState,
  formData: FormData,
): Promise<AuthState> {
  const email = String(formData.get("email") ?? "").trim();
  const password = String(formData.get("password") ?? "");

  if (!email || !password) {
    return { error: "Email and password are required." };
  }

  const res = await apiClient.post<AuthResult>("/auth/admin-login", {
    email,
    password,
  });

  if (!res.success || !res.data) {
    return { error: res.message || "Unauthorized administrator credentials." };
  }

  const cookieStore = await cookies();
  cookieStore.set(AUTH_COOKIE_NAME, res.data.token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge: 7 * 24 * 60 * 60,
  });

  revalidatePath("/", "layout");
  redirect("/admin");
}

export async function logout() {
  const cookieStore = await cookies();
  cookieStore.delete(AUTH_COOKIE_NAME);
  revalidatePath("/", "layout");
  redirect("/");
}
