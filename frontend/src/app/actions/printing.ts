"use server";

import { revalidatePath } from "next/cache";
import { apiClient } from "@/lib/api-client";
import { requireProfile } from "@/lib/auth";

export type ActionState = { error?: string; success?: string };

export async function createPrintOrder(
  _prev: ActionState,
  formData: FormData,
): Promise<ActionState> {
  const session = await requireProfile();
  if (!session) return { error: "You must be signed in." };

  const service_type = String(formData.get("service_type") ?? "document").toUpperCase();
  const description = String(formData.get("description") ?? "").trim() || null;
  const copies = Math.max(1, Number(formData.get("copies") ?? 1));
  const color = formData.get("color") === "on";

  const res = await apiClient.post<{ estimatedPrice?: number }>("/orders", {
    serviceType: service_type,
    description,
    copies,
    color,
  });

  if (!res.success) {
    return { error: res.message || "Failed to submit print order." };
  }

  const estimated_price = res.data?.estimatedPrice;

  revalidatePath("/dashboard/printing");
  revalidatePath("/dashboard");
  return {
    success: `Order submitted.${estimated_price ? ` Estimated cost: TZS ${estimated_price.toLocaleString()}.` : ""}`,
  };
}
