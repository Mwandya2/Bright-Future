import { createClient } from "@/lib/supabase/server";
import { requireProfile } from "@/lib/auth";
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
  const { user } = await requireProfile();
  const supabase = await createClient();
  const { data } = await supabase
    .from("lab_bookings")
    .select("*")
    .eq("user_id", user.id)
    .order("booking_date", { ascending: false });

  const bookings = (data ?? []) as LabBooking[];

  return (
    <div className="mx-auto max-w-5xl">
      <h1 className="font-display text-3xl md:text-4xl">Computer lab bookings</h1>
      <p className="mt-2 text-[15px] text-[var(--color-body)]">
        Reserve a workstation and manage your sessions.
      </p>

      <div className="mt-8 grid gap-6 lg:grid-cols-[1fr_1.2fr]">
        <Card className="h-fit p-6">
          <h2 className="text-[18px] font-medium text-[var(--color-ink)]">New booking</h2>
          <div className="mt-4">
            <BookingForm />
          </div>
        </Card>

        <Card className="p-6">
          <h2 className="text-[18px] font-medium text-[var(--color-ink)]">Your bookings</h2>
          {bookings.length === 0 ? (
            <p className="mt-4 text-[14px] text-[var(--color-body)]">No bookings yet.</p>
          ) : (
            <ul className="mt-4 divide-y divide-[var(--color-hairline)]">
              {bookings.map((b) => (
                <li key={b.id} className="flex items-center justify-between py-3">
                  <div>
                    <div className="text-[15px] font-medium capitalize text-[var(--color-ink)]">
                      {b.workstation_type.replace("_", " ")}
                    </div>
                    <div className="text-[13px] text-[var(--color-muted)]">
                      {b.booking_date} · {b.start_time} · {b.duration_hours}h
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className={`text-[12px] font-semibold uppercase ${statusColor[b.status]}`}>
                      {b.status}
                    </span>
                    {b.status !== "cancelled" && b.status !== "completed" && (
                      <form action={cancelBooking}>
                        <input type="hidden" name="id" value={b.id} />
                        <button className="text-[13px] font-medium text-[var(--color-error)] hover:underline">
                          Cancel
                        </button>
                      </form>
                    )}
                  </div>
                </li>
              ))}
            </ul>
          )}
        </Card>
      </div>
    </div>
  );
}
