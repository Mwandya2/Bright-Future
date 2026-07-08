"use server";

import { revalidatePath } from "next/cache";
import { requireProfile } from "@/lib/auth";
import { createAdminClient } from "@/lib/supabase/admin";
import { ADMIN_EMAIL } from "@/lib/admin";

async function assertAdmin() {
  await requireProfile({ admin: true });
  return createAdminClient();
}

function slugify(s: string) {
  return s
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");
}

export type AdminState = { error?: string; success?: string };

export async function createCourse(
  _prev: AdminState,
  formData: FormData,
): Promise<AdminState> {
  const supabase = await assertAdmin();

  const title = String(formData.get("title") ?? "").trim();
  if (!title) return { error: "Title is required." };

  const { error } = await supabase.from("courses").insert({
    title,
    slug: `${slugify(title)}-${Math.random().toString(36).slice(2, 6)}`,
    summary: String(formData.get("summary") ?? "").trim() || null,
    category: String(formData.get("category") ?? "ict"),
    level: String(formData.get("level") ?? "beginner"),
    price: Number(formData.get("price") ?? 0),
    duration_weeks: Number(formData.get("duration_weeks") ?? 4),
    instructor_name: String(formData.get("instructor_name") ?? "").trim() || null,
    cover_gradient: String(formData.get("cover_gradient") ?? "mint"),
    is_published: formData.get("is_published") === "on",
  });

  if (error) return { error: error.message };
  revalidatePath("/admin/courses");
  revalidatePath("/courses");
  return { success: "Course created." };
}

export async function togglePublish(formData: FormData) {
  const supabase = await assertAdmin();
  const id = String(formData.get("id"));
  const next = formData.get("is_published") === "true";
  await supabase.from("courses").update({ is_published: next }).eq("id", id);
  revalidatePath("/admin/courses");
  revalidatePath("/courses");
}

export async function deleteCourse(formData: FormData) {
  const supabase = await assertAdmin();
  await supabase.from("courses").delete().eq("id", String(formData.get("id")));
  revalidatePath("/admin/courses");
  revalidatePath("/courses");
}

export async function updateBookingStatus(formData: FormData) {
  const supabase = await assertAdmin();
  await supabase
    .from("lab_bookings")
    .update({ status: String(formData.get("status")) })
    .eq("id", String(formData.get("id")));
  revalidatePath("/admin/bookings");
}

export async function updateOrderStatus(formData: FormData) {
  const supabase = await assertAdmin();
  await supabase
    .from("print_orders")
    .update({ status: String(formData.get("status")) })
    .eq("id", String(formData.get("id")));
  revalidatePath("/admin/orders");
}

export async function setUserRole(formData: FormData) {
  const supabase = await assertAdmin();
  const id = String(formData.get("id"));
  const role = String(formData.get("role"));
  // Single-admin lock: nobody can be promoted to admin through the UI…
  if (role === "admin") return;
  // …and the designated admin's own role can't be changed away (lockout guard).
  const { data: target } = await supabase
    .from("profiles")
    .select("email")
    .eq("id", id)
    .single();
  if (target?.email && target.email.toLowerCase() === ADMIN_EMAIL) return;

  await supabase.from("profiles").update({ role }).eq("id", id);
  revalidatePath("/admin/users");
}
