"use server";

import { apiClient } from "@/lib/api-client";

export type ContactState = { error?: string; success?: string };

export async function sendContactMessage(
  _prev: ContactState,
  formData: FormData,
): Promise<ContactState> {
  const name = String(formData.get("name") ?? "").trim();
  const email = String(formData.get("email") ?? "").trim();
  const subject = String(formData.get("subject") ?? "").trim() || null;
  const message = String(formData.get("message") ?? "").trim();

  if (!name || !email || !message) {
    return { error: "Please fill in your name, email, and message." };
  }

  const res = await apiClient.post("/contact", {
    name,
    email,
    subject,
    message,
  });

  if (!res.success) {
    return { error: res.message || "Failed to send message." };
  }

  return { success: "Thanks! Your message has been sent — we'll be in touch." };
}
