"use server";

import { createClient } from "@/lib/supabase/server";

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

  const supabase = await createClient();
  const { error } = await supabase
    .from("contact_messages")
    .insert({ name, email, subject, message });

  if (error) return { error: error.message };

  return { success: "Thanks! Your message has been sent — we'll be in touch." };
}
