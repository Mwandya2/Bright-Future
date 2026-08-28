"use server";

import { revalidatePath } from "next/cache";
import { requireProfile } from "@/lib/auth";
import { apiClient } from "@/lib/api-client";

async function assertAdmin() {
  await requireProfile({ admin: true });
}

export type AdminState = { error?: string; success?: string };

export async function createCourse(
  _prev: AdminState,
  formData: FormData,
): Promise<AdminState> {
  await assertAdmin();

  const title = String(formData.get("title") ?? "").trim();
  if (!title) return { error: "Title is required." };

  const payload = {
    title,
    summary: String(formData.get("summary") ?? "").trim() || null,
    category: String(formData.get("category") ?? "ict"),
    level: String(formData.get("level") ?? "beginner").toUpperCase(),
    price: Number(formData.get("price") ?? 0),
    durationWeeks: Number(formData.get("duration_weeks") ?? 4),
    instructorName: String(formData.get("instructor_name") ?? "").trim() || null,
    coverGradient: String(formData.get("cover_gradient") ?? "mint"),
    isPublished: formData.get("is_published") === "on",
  };

  const res = await apiClient.post("/courses", payload);
  if (!res.success) return { error: res.message || "Failed to create course." };

  revalidatePath("/admin/courses");
  revalidatePath("/courses");
  return { success: "Course created successfully." };
}

export async function togglePublish(formData: FormData) {
  await assertAdmin();
  const id = String(formData.get("id"));
  const next = formData.get("is_published") === "true";

  await apiClient.patch(`/courses/${id}/publish?isPublished=${next}`);
  revalidatePath("/admin/courses");
  revalidatePath("/courses");
}

export async function deleteCourse(formData: FormData) {
  await assertAdmin();
  const id = String(formData.get("id"));

  await apiClient.delete(`/courses/${id}`);
  revalidatePath("/admin/courses");
  revalidatePath("/courses");
}

export async function updateBookingStatus(formData: FormData) {
  await assertAdmin();
  const id = String(formData.get("id"));
  const status = String(formData.get("status")).toUpperCase();

  await apiClient.patch(`/bookings/${id}/status`, { status });
  revalidatePath("/admin/bookings");
}

export async function updateOrderStatus(formData: FormData) {
  await assertAdmin();
  const id = String(formData.get("id"));
  const status = String(formData.get("status")).toUpperCase();

  await apiClient.patch(`/orders/${id}/status`, { status });
  revalidatePath("/admin/orders");
}

export async function setUserRole(formData: FormData) {
  await assertAdmin();
  const id = String(formData.get("id"));
  const role = String(formData.get("role")).toUpperCase();

  if (role === "ADMIN") return;

  await apiClient.patch(`/admin/users/${id}/role`, { role });
  revalidatePath("/admin/users");
}
