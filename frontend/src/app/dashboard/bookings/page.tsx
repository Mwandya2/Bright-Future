import { requireProfile } from "@/lib/auth";
import { apiClient } from "@/lib/api-client";
import { Card } from "@/components/ui";
import { BookingForm } from "@/components/booking-form";
import { cancelBooking } from "@/app/actions/bookings";
import type { LabBooking } from "@/lib/types";

export const metadata = { title: "Lab Bookings" };

const statusColor: Record<string, string> = {
  pending: "text-[var(--color-muted)]",
  confirmed: "text-[var(--color-success)]",
  completed: "text-[var(--color-muted)]",
  cancelled: "text-[var(--color-error)]",
};

export default async function BookingsPage() {
  await requireProfile();
  const res = await apiClient.get<LabBooking[]>("/bookings/my");
  const bookings = res.data ?? [];

  return (
    <div className="mx-auto max-w-5xl">
      <h1 className="font-display text-2xl sm:text-3xl md:text-4xl">Computer lab bookings</h1>
      <p className="mt-2 text-[14px] sm:text-[15px] text-[var(--color-body)]">
        Reserve a workstation and manage your sessions.
      </p>

      <div className="mt-6 sm:mt-8 grid gap-6 grid-cols-1 lg:grid-cols-[1fr_1.2fr]">
        <Card className="h-fit p-5 sm:p-6">
          <h2 className="text-[17px] sm:text-[18px] font-medium text-[var(--color-ink)]">New booking</h2>
          <div className="mt-4">
            <BookingForm />
          </div>
        </Card>

        <Card className="p-5 sm:p-6">
          <h2 className="text-[17px] sm:text-[18px] font-medium text-[var(--color-ink)]">Your bookings</h2>
          {bookings.length === 0 ? (
            <p className="mt-4 text-[14px] text-[var(--color-body)]">No bookings yet.</p>
          ) : (
            <ul className="mt-4 divide-y divide-[var(--color-hairline)]">
              {bookings.map((b) => {
                const wsType = (b.workstation_type ?? (b as unknown as { workstationType?: string }).workstationType ?? "computer")
                  .toString()
                  .toLowerCase()
                  .replace("_", " ");
                const bDate = b.booking_date ?? (b as unknown as { bookingDate?: string }).bookingDate;
                const bTime = b.start_time ?? (b as unknown as { startTime?: string }).startTime;
                const bHours = b.duration_hours ?? (b as unknown as { durationHours?: number }).durationHours ?? 1;
                const statusStr = String(b.status).toLowerCase();

                return (
                  <li key={b.id} className="flex flex-col sm:flex-row sm:items-center sm:justify-between py-3 gap-2">
                    <div>
                      <div className="text-[14px] sm:text-[15px] font-medium capitalize text-[var(--color-ink)]">
                        {wsType}
                      </div>
                      <div className="text-[12px] sm:text-[13px] text-[var(--color-muted)]">
                        {bDate} · {bTime} · {bHours}h
                      </div>
                    </div>
                    <div className="flex items-center gap-3 self-end sm:self-auto">
                      <span className={`text-[11px] sm:text-[12px] font-semibold uppercase ${statusColor[statusStr] || "text-[var(--color-muted)]"}`}>
                        {b.status}
                      </span>
                      {statusStr !== "cancelled" && statusStr !== "completed" && (
                        <form action={cancelBooking}>
                          <input type="hidden" name="id" value={b.id} />
                          <button className="text-[12px] sm:text-[13px] font-medium text-[var(--color-error)] hover:underline min-h-[32px] px-2 py-1">
                            Cancel
                          </button>
                        </form>
                      )}
                    </div>
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
