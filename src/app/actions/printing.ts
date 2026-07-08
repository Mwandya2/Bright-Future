"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type ActionState = { error?: string; success?: string };

// Simple indicative pricing (TZS) for the estimate.
const BASE: Record<string, number> = {
  document: 200,
  poster: 8000,
  banner: 25000,
  business_card: 15000,
  photo: 1000,
};

export async function createPrintOrder(
  _prev: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: "You must be signed in." };

  const service_type = String(formData.get("service_type") ?? "document");
  const description = String(formData.get("description") ?? "").trim() || null;
  const copies = Math.max(1, Number(formData.get("copies") ?? 1));
  const color = formData.get("color") === "on";

  const unit = BASE[service_type] ?? 200;
  const estimated_price = Math.round(unit * copies * (color ? 1.5 : 1));

  const { error } = await supabase.from("print_orders").insert({
    user_id: user.id,
    service_type,
    description,
    copies,
    color,
    estimated_price,
  });

  if (error) return { error: error.message };

  revalidatePath("/dashboard/printing");
  revalidatePath("/dashboard");
  return {
    success: `Order submitted. Estimated cost: TZS ${estimated_price.toLocaleString()}.`,
  };
}
