import { apiClient } from "@/lib/api-client";
import { requireProfile } from "@/lib/auth";
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
  await requireProfile({ admin: true });
  const res = await apiClient.get<PrintOrder[]>("/orders");
  const orders = res.data ?? [];

  return (
    <div className="mx-auto max-w-6xl">
      <h1 className="font-display text-2xl sm:text-3xl md:text-4xl">Print orders</h1>
      <p className="mt-2 text-[14px] sm:text-[15px] text-[var(--color-body)]">
        Manage digital printing requests through to collection.
      </p>

      <Card className="mt-6 sm:mt-8 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full min-w-[580px] whitespace-nowrap text-left text-[14px]">
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
                orders.map((o) => {
                  const memberName = o.user?.fullName ?? o.user?.email ?? o.profile?.full_name ?? "—";
                  const memberEmail = o.user?.email ?? o.profile?.email ?? "";
                  const sType = (o.service_type ?? (o as unknown as { serviceType?: string }).serviceType ?? "document")
                    .toString()
                    .toLowerCase()
                    .replace("_", " ");
                  const estPrice = o.estimated_price ?? (o as unknown as { estimatedPrice?: number }).estimatedPrice;
                  const currentStatus = String(o.status).toLowerCase();

                  return (
                    <tr key={o.id}>
                      <td className="px-5 py-3">
                        <div className="font-medium text-[var(--color-ink)]">
                          {memberName}
                        </div>
                        <div className="text-[12px] text-[var(--color-muted)]">{memberEmail}</div>
                      </td>
                      <td className="px-5 py-3 capitalize text-[var(--color-body-strong)]">
                        {sType}
                      </td>
                      <td className="px-5 py-3 text-[var(--color-body)]">
                        {o.copies}× · {o.color ? "Color" : "B/W"}
                      </td>
                      <td className="px-5 py-3 text-[var(--color-body-strong)]">
                        {estPrice ? `TZS ${estPrice.toLocaleString()}` : "—"}
                      </td>
                      <td className="px-5 py-3">
                        <form action={updateOrderStatus}>
                          <input type="hidden" name="id" value={o.id} />
                          <StatusSelect name="status" defaultValue={currentStatus} options={STATUSES} />
                        </form>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
