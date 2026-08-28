import { apiClient } from "@/lib/api-client";
import { requireProfile } from "@/lib/auth";
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
  await requireProfile({ admin: true });
  const res = await apiClient.get<LabBooking[]>("/bookings");
  const bookings = res.data ?? [];

  return (
    <div className="mx-auto max-w-6xl">
      <h1 className="font-display text-2xl sm:text-3xl md:text-4xl">Lab bookings</h1>
      <p className="mt-2 text-[14px] sm:text-[15px] text-[var(--color-body)]">
        Review and update all workstation bookings.
      </p>

      <Card className="mt-6 sm:mt-8 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full min-w-[580px] whitespace-nowrap text-left text-[14px]">
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
                bookings.map((b) => {
                  const memberName = b.user?.fullName ?? b.user?.email ?? b.profile?.full_name ?? "—";
                  const memberEmail = b.user?.email ?? b.profile?.email ?? "";
                  const wsType = (b.workstation_type ?? (b as unknown as { workstationType?: string }).workstationType ?? "computer")
                    .toString()
                    .toLowerCase()
                    .replace("_", " ");
                  const bDate = b.booking_date ?? (b as unknown as { bookingDate?: string }).bookingDate;
                  const bTime = b.start_time ?? (b as unknown as { startTime?: string }).startTime;
                  const bHours = b.duration_hours ?? (b as unknown as { durationHours?: number }).durationHours ?? 1;
                  const currentStatus = String(b.status).toLowerCase();

                  return (
                    <tr key={b.id}>
                      <td className="px-5 py-3">
                        <div className="font-medium text-[var(--color-ink)]">
                          {memberName}
                        </div>
                        <div className="text-[12px] text-[var(--color-muted)]">
                          {memberEmail}
                        </div>
                      </td>
                      <td className="px-5 py-3 capitalize text-[var(--color-body-strong)]">
                        {wsType}
                      </td>
                      <td className="px-5 py-3 text-[var(--color-body)]">
                        {bDate} · {bTime} · {bHours}h
                      </td>
                      <td className="px-5 py-3">
                        <form action={updateBookingStatus}>
                          <input type="hidden" name="id" value={b.id} />
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
