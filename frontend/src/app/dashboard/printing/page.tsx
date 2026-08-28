import { requireProfile } from "@/lib/auth";
import { apiClient } from "@/lib/api-client";
import { Card } from "@/components/ui";
import { PrintForm } from "@/components/print-form";
import type { PrintOrder } from "@/lib/types";

export const metadata = { title: "Digital Printing" };

export default async function PrintingPage() {
  await requireProfile();
  const res = await apiClient.get<PrintOrder[]>("/orders/my");
  const orders = res.data ?? [];

  return (
    <div className="mx-auto max-w-5xl">
      <h1 className="font-display text-2xl sm:text-3xl md:text-4xl">Digital printing</h1>
      <p className="mt-2 text-[14px] sm:text-[15px] text-[var(--color-body)]">
        Submit documents, posters, banners, cards, and photos for printing.
      </p>

      <div className="mt-6 sm:mt-8 grid gap-6 grid-cols-1 lg:grid-cols-[1fr_1.2fr]">
        <Card className="h-fit p-5 sm:p-6">
          <h2 className="text-[17px] sm:text-[18px] font-medium text-[var(--color-ink)]">New print order</h2>
          <div className="mt-4">
            <PrintForm />
          </div>
        </Card>

        <Card className="p-5 sm:p-6">
          <h2 className="text-[17px] sm:text-[18px] font-medium text-[var(--color-ink)]">Your orders</h2>
          {orders.length === 0 ? (
            <p className="mt-4 text-[14px] text-[var(--color-body)]">No orders yet.</p>
          ) : (
            <ul className="mt-4 divide-y divide-[var(--color-hairline)]">
              {orders.map((o) => {
                const sType = (o.service_type ?? (o as unknown as { serviceType?: string }).serviceType ?? "document")
                  .toString()
                  .toLowerCase()
                  .replace("_", " ");
                const estPrice = o.estimated_price ?? (o as unknown as { estimatedPrice?: number }).estimatedPrice;
                const statusStr = String(o.status).toLowerCase().replace("_", " ");

                return (
                  <li key={o.id} className="flex flex-col sm:flex-row sm:items-center sm:justify-between py-3 gap-2">
                    <div>
                      <div className="text-[14px] sm:text-[15px] font-medium capitalize text-[var(--color-ink)]">
                        {sType}
                      </div>
                      <div className="text-[12px] sm:text-[13px] text-[var(--color-muted)]">
                        {o.copies} {o.copies > 1 ? "copies" : "copy"} · {o.color ? "Color" : "B/W"}
                        {estPrice ? ` · ~TZS ${estPrice.toLocaleString()}` : ""}
                      </div>
                    </div>
                    <span className="self-start sm:self-auto rounded-full bg-[var(--color-surface-strong)] px-2.5 py-1 text-[10px] sm:text-[11px] font-semibold uppercase text-[var(--color-muted)]">
                      {statusStr}
                    </span>
                  </li>
                );
              })}
            </ul>
          )}
        </Card>
      </div>
    </div>
  );
}
