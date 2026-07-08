"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";
import { sendBookingConfirmation } from "@/lib/resend";

export type ActionState = { error?: string; success?: string };

export async function createBooking(
  _prev: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "You must be signed in." };

  const workstation_type = String(formData.get("workstation_type") ?? "computer");
  const booking_date = String(formData.get("booking_date") ?? "");
  const start_time = String(formData.get("start_time") ?? "");
  const duration_hours = Number(formData.get("duration_hours") ?? 1);
  const notes = String(formData.get("notes") ?? "").trim() || null;

  if (!booking_date || !start_time) {
    return { error: "Please choose a date and start time." };
  }

  const { error } = await supabase.from("lab_bookings").insert({
    user_id: user.id,
    workstation_type,
    booking_date,
    start_time,
    duration_hours,
    notes,
  });

  if (error) return { error: error.message };

  const { data: profile } = await supabase
    .from("profiles")
    .select("full_name, email")
    .eq("id", user.id)
    .single();

  if (profile?.email) {
    await sendBookingConfirmation(profile.email, profile.full_name ?? "", {
      service: `${workstation_type.replace("_", " ")} workstation`,
      date: booking_date,
      time: start_time,
    });
  }

  revalidatePath("/dashboard/bookings");
  revalidatePath("/dashboard");
  return { success: "Booking requested — check your email for confirmation." };
}

export async function cancelBooking(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  const supabase = await createClient();
  await supabase.from("lab_bookings").update({ status: "cancelled" }).eq("id", id);
  revalidatePath("/dashboard/bookings");
}
