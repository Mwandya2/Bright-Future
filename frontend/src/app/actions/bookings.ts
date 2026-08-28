"use server";

import { revalidatePath } from "next/cache";
import { apiClient } from "@/lib/api-client";
import { requireProfile } from "@/lib/auth";
import { sendBookingConfirmation } from "@/lib/resend";

export type ActionState = { error?: string; success?: string };

export async function createBooking(
  _prev: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const session = await requireProfile();
  if (!session) return { error: "You must be signed in." };

  const workstation_type = String(formData.get("workstation_type") ?? "computer").toUpperCase();
  const booking_date = String(formData.get("booking_date") ?? "");
  const start_time = String(formData.get("start_time") ?? "");
  const duration_hours = Number(formData.get("duration_hours") ?? 1);
  const notes = String(formData.get("notes") ?? "").trim() || null;

  if (!booking_date || !start_time) {
    return { error: "Please choose a date and start time." };
  }

  // Format time as HH:mm:ss if it's HH:mm
  const formattedTime = start_time.length === 5 ? `${start_time}:00` : start_time;

  const res = await apiClient.post("/bookings", {
    workstationType: workstation_type,
    bookingDate: booking_date,
    startTime: formattedTime,
    durationHours: duration_hours,
    notes,
  });

  if (!res.success) {
    return { error: res.message || "Failed to create booking." };
  }

  if (session.profile.email) {
    try {
      await sendBookingConfirmation(session.profile.email, session.profile.full_name ?? "", {
        service: `${workstation_type.toLowerCase().replace("_", " ")} workstation`,
        date: booking_date,
        time: start_time,
      });
    } catch (err) {
      console.error("Booking confirmation email error:", err);
    }
  }

  revalidatePath("/dashboard/bookings");
  revalidatePath("/dashboard");
  return { success: "Booking requested — check your email for confirmation." };
}

export async function cancelBooking(formData: FormData) {
  const id = String(formData.get("id") ?? "");
  await apiClient.patch(`/bookings/${id}/cancel`);
  revalidatePath("/dashboard/bookings");
  revalidatePath("/dashboard");
}
