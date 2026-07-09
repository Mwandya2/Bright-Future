"use server";

import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { isTheAdmin } from "@/lib/admin";

/**
 * Enrol the CURRENTLY signed-in user into a course. If they're already signed
 * in we never ask them to create an account again — we just enrol them. Only
 * signed-out visitors are sent to sign in (and returned to the catalogue).
 */
export async function enrollSelf(formData: FormData) {
  const courseId = String(formData.get("course_id") ?? "");
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Not signed in → go sign in, then come back to the courses page.
  if (!user) {
    redirect("/login?redirect=/courses");
  }

  // Admin is oversight-only — never enrols; send them to manage the catalogue.
  const { data: prof } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", user.id)
    .single();
  if (isTheAdmin(user.email, prof?.role)) {
    redirect("/admin/courses");
  }

  if (courseId) {
    // Upsert so re-clicking "Enroll" for a course you already have is a no-op.
    await supabase
      .from("enrollments")
      .upsert(
        { user_id: user.id, course_id: courseId },
        { onConflict: "user_id,course_id", ignoreDuplicates: true },
      );
  }

  revalidatePath("/dashboard/courses");
  redirect("/dashboard/courses");
}
