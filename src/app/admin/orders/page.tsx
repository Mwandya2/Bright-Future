import { createAdminClient } from "@/lib/supabase/admin";
import { Card } from "@/components/ui";
import { StatusSelect } from "@/components/status-select";
import { updateOrderStatus } from "@/app/actions/admin";
import type { PrintOrder } from "@/lib/types";

export const metadata = { title: "Print Orders" };

const STATUSES = [
  { value: "submitted", label: "Submitted" },
  { value: "in_progress", label: "In progress" },
  { value: "ready", label: "Ready" },
  { value: "collected", label: "Collected" },
  { value: "cancelled", label: "Cancelled" },
];

export default async function AdminOrdersPage() {
  const supabase = createAdminClient();
  const { data } = await supabase
    .from("print_orders")
    .select("*, profile:profiles(full_name, email)")
    .order("created_at", { ascending: false });
  const orders = (data ?? []) as PrintOrder[];

  return (
    <div className="mx-auto max-w-6xl">
      <h1 className="font-display text-3xl md:text-4xl">Print orders</h1>
      <p className="mt-2 text-[15px] text-[var(--color-body)]">
        Manage digital printing requests through to collection.
      </p>

      <Card className="mt-8 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full min-w-[640px] whitespace-nowrap text-left text-[14px]">
            <thead className="border-b border-[var(--color-hairline)] bg-[var(--color-canvas-soft)] text-[12px] uppercase tracking-[0.06em] text-[var(--color-muted)]">
              <tr>
                <th className="px-5 py-3 font-semibold">Member</th>
                <th className="px-5 py-3 font-semibold">Service</th>
                <th className="px-5 py-3 font-semibold">Details</th>
                <th className="px-5 py-3 font-semibold">Est.</th>
                <th className="px-5 py-3 font-semibold">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[var(--color-hairline)]">
              {orders.length === 0 ? (
                <tr>
                  <td colSpan={5} className="px-5 py-8 text-center text-[var(--color-muted)]">
                    No print orders yet.
                  </td>
                </tr>
              ) : (
                orders.map((o) => (
                  <tr key={o.id}>
                    <td className="px-5 py-3">
                      <div className="font-medium text-[var(--color-ink)]">
                        {o.profile?.full_name ?? "—"}
                      </div>
                      <div className="text-[12px] text-[var(--color-muted)]">{o.profile?.email}</div>
                    </td>
                    <td className="px-5 py-3 capitalize text-[var(--color-body-strong)]">
                      {o.service_type.replace("_", " ")}
                    </td>
                    <td className="px-5 py-3 text-[var(--color-body)]">
                      {o.copies}× · {o.color ? "Color" : "B/W"}
                    </td>
                    <td className="px-5 py-3 text-[var(--color-body-strong)]">
                      {o.estimated_price ? `TZS ${o.estimated_price.toLocaleString()}` : "—"}
                    </td>
                    <td className="px-5 py-3">
                      <form action={updateOrderStatus}>
                        <input type="hidden" name="id" value={o.id} />
                        <StatusSelect name="status" defaultValue={o.status} options={STATUSES} />
                      </form>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
