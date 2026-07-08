import { createClient } from "@/lib/supabase/server";
import { requireProfile } from "@/lib/auth";
import { Card } from "@/components/ui";
import { PrintForm } from "@/components/print-form";
import type { PrintOrder } from "@/lib/types";

export const metadata = { title: "Digital Printing" };

export default async function PrintingPage() {
  const { user } = await requireProfile();
  const supabase = await createClient();
  const { data } = await supabase
    .from("print_orders")
    .select("*")
    .eq("user_id", user.id)
    .order("created_at", { ascending: false });

  const orders = (data ?? []) as PrintOrder[];

  return (
    <div className="mx-auto max-w-5xl">
      <h1 className="font-display text-3xl md:text-4xl">Digital printing</h1>
      <p className="mt-2 text-[15px] text-[var(--color-body)]">
        Submit documents, posters, banners, cards, and photos for printing.
      </p>

      <div className="mt-8 grid gap-6 lg:grid-cols-[1fr_1.2fr]">
        <Card className="h-fit p-6">
          <h2 className="text-[18px] font-medium text-[var(--color-ink)]">New print order</h2>
          <div className="mt-4">
            <PrintForm />
          </div>
        </Card>

        <Card className="p-6">
          <h2 className="text-[18px] font-medium text-[var(--color-ink)]">Your orders</h2>
          {orders.length === 0 ? (
            <p className="mt-4 text-[14px] text-[var(--color-body)]">No orders yet.</p>
          ) : (
            <ul className="mt-4 divide-y divide-[var(--color-hairline)]">
              {orders.map((o) => (
                <li key={o.id} className="flex items-center justify-between py-3">
                  <div>
                    <div className="text-[15px] font-medium capitalize text-[var(--color-ink)]">
                      {o.service_type.replace("_", " ")}
                    </div>
                    <div className="text-[13px] text-[var(--color-muted)]">
                      {o.copies} {o.copies > 1 ? "copies" : "copy"} · {o.color ? "Color" : "B/W"}
                      {o.estimated_price ? ` · ~TZS ${o.estimated_price.toLocaleString()}` : ""}
                    </div>
                  </div>
                  <span className="rounded-full bg-[var(--color-surface-strong)] px-2.5 py-1 text-[11px] font-semibold uppercase text-[var(--color-muted)]">
                    {o.status.replace("_", " ")}
                  </span>
                </li>
              ))}
            </ul>
          )}
        </Card>
      </div>
    </div>
  );
}
