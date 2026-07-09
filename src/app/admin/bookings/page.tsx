import { createAdminClient } from "@/lib/supabase/admin";
import { Card } from "@/components/ui";
import { StatusSelect } from "@/components/status-select";
import { updateBookingStatus } from "@/app/actions/admin";
import type { LabBooking } from "@/lib/types";

export const metadata = { title: "All Bookings" };

const STATUSES = [
  { value: "pending", label: "Pending" },
  { value: "confirmed", label: "Confirmed" },
  { value: "completed", label: "Completed" },
  { value: "cancelled", label: "Cancelled" },
];

export default async function AdminBookingsPage() {
  const supabase = createAdminClient();
  const { data } = await supabase
    .from("lab_bookings")
    .select("*, profile:profiles(full_name, email)")
    .order("booking_date", { ascending: false });
  const bookings = (data ?? []) as LabBooking[];

  return (
    <div className="mx-auto max-w-6xl">
      <h1 className="font-display text-3xl md:text-4xl">Lab bookings</h1>
      <p className="mt-2 text-[15px] text-[var(--color-body)]">
        Review and update all workstation bookings.
      </p>

      <Card className="mt-8 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full min-w-[640px] whitespace-nowrap text-left text-[14px]">
            <thead className="border-b border-[var(--color-hairline)] bg-[var(--color-canvas-soft)] text-[12px] uppercase tracking-[0.06em] text-[var(--color-muted)]">
              <tr>
                <th className="px-5 py-3 font-semibold">Member</th>
                <th className="px-5 py-3 font-semibold">Workstation</th>
                <th className="px-5 py-3 font-semibold">Date / Time</th>
                <th className="px-5 py-3 font-semibold">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[var(--color-hairline)]">
              {bookings.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-5 py-8 text-center text-[var(--color-muted)]">
                    No bookings yet.
                  </td>
                </tr>
              ) : (
                bookings.map((b) => (
                  <tr key={b.id}>
                    <td className="px-5 py-3">
                      <div className="font-medium text-[var(--color-ink)]">
                        {b.profile?.full_name ?? "—"}
                      </div>
                      <div className="text-[12px] text-[var(--color-muted)]">
                        {b.profile?.email}
                      </div>
                    </td>
                    <td className="px-5 py-3 capitalize text-[var(--color-body-strong)]">
                      {b.workstation_type.replace("_", " ")}
                    </td>
                    <td className="px-5 py-3 text-[var(--color-body)]">
                      {b.booking_date} · {b.start_time} · {b.duration_hours}h
                    </td>
                    <td className="px-5 py-3">
                      <form action={updateBookingStatus}>
                        <input type="hidden" name="id" value={b.id} />
                        <StatusSelect name="status" defaultValue={b.status} options={STATUSES} />
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
