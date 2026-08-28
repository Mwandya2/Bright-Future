"use server";

import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { getOptionalProfile } from "@/lib/auth";
import { apiClient } from "@/lib/api-client";
import { isTheAdmin } from "@/lib/admin";

export async function enrollSelf(formData: FormData) {
  const courseId = String(formData.get("course_id") ?? "");
  const session = await getOptionalProfile();

  if (!session) {
    redirect("/login?redirect=/courses");
  }

  if (isTheAdmin(session.user.email, session.profile.role)) {
    redirect("/admin/courses");
  }

  if (courseId) {
    await apiClient.post("/enrollments", { courseId });
  }

  revalidatePath("/dashboard/courses");
  redirect("/dashboard/courses");
}
