import { Users, BookOpen, MonitorSmartphone, Printer } from "lucide-react";
import { apiClient } from "@/lib/api-client";
import { requireProfile } from "@/lib/auth";
import { Card } from "@/components/ui";
import type { AdminStats, LabBooking, PrintOrder } from "@/lib/types";

export const metadata = { title: "Admin Overview" };

export default async function AdminHome() {
  await requireProfile({ admin: true });

  const [statsRes, bookingsRes, ordersRes] = await Promise.all([
    apiClient.get<AdminStats>("/admin/stats"),
    apiClient.get<LabBooking[]>("/bookings"),
    apiClient.get<PrintOrder[]>("/orders"),
  ]);

  const statsData = statsRes.data;
  const recentBookings = (bookingsRes.data ?? []).slice(0, 5);
  const orders = ordersRes.data ?? [];

  const revenue = orders.reduce(
    (sum, o) => sum + (o.estimated_price ?? (o as unknown as { estimatedPrice?: number }).estimatedPrice ?? 0),
    0,
  );

  const stats = [
    { label: "Total users", value: statsData?.totalUsers ?? 0, icon: <Users />, chip: "chip-mint" },
    { label: "Courses", value: statsData?.totalCourses ?? 0, icon: <BookOpen />, chip: "chip-sky" },
    { label: "Lab bookings", value: statsData?.totalBookings ?? 0, icon: <MonitorSmartphone />, chip: "chip-lavender" },
    { label: "Print orders", value: statsData?.totalPrintOrders ?? 0, icon: <Printer />, chip: "chip-peach" },
  ];

  return (
    <div className="mx-auto max-w-6xl">
      <h1 className="font-display text-2xl sm:text-3xl md:text-4xl">Admin overview</h1>
      <p className="mt-2 text-[14px] sm:text-[15px] text-[var(--color-body)]">
        Platform activity across Bright Future Digital Hub.
      </p>

      <div className="mt-6 sm:mt-8 grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((s) => (
          <Card key={s.label} className="relative overflow-hidden p-5 sm:p-6">
            <div className={`absolute inset-x-0 top-0 h-1 ${s.chip}`} />
            <div className="flex items-start justify-between">
              <div>
                <div className="font-display tnum text-3xl sm:text-4xl">{s.value}</div>
                <div className="mt-1 text-[13px] sm:text-[14px] text-[var(--color-muted)]">{s.label}</div>
              </div>
              <span className={`grid h-10 w-10 place-items-center rounded-xl ${s.chip} text-[var(--color-ink)] [&_svg]:h-5 [&_svg]:w-5`}>
                {s.icon}
              </span>
            </div>
          </Card>
        ))}
      </div>

      <div className="mt-6 grid gap-6 grid-cols-1 lg:grid-cols-[1fr_1.4fr]">
        <Card className="bg-[var(--color-surface-dark)] p-5 sm:p-6 text-white">
          <div className="text-[12px] sm:text-[13px] uppercase tracking-[0.08em] text-[var(--color-on-dark-soft)]">
            Estimated printing revenue
          </div>
          <div className="font-display tnum mt-3 text-3xl sm:text-4xl text-white">
            TZS {revenue.toLocaleString()}
          </div>
          <p className="mt-2 text-[12px] sm:text-[13px] text-[var(--color-on-dark-soft)]">
            Sum of print-order estimates across the platform.
          </p>
        </Card>

        <Card className="p-5 sm:p-6">
          <h2 className="text-[17px] sm:text-[18px] font-medium text-[var(--color-ink)]">Recent bookings</h2>
          {recentBookings && recentBookings.length > 0 ? (
            <ul className="mt-4 divide-y divide-[var(--color-hairline)]">
              {recentBookings.map((b) => {
                const userName = b.user?.fullName ?? b.user?.email ?? b.profile?.full_name ?? b.profile?.email ?? "Student";
                const wsType = (b.workstation_type ?? (b as unknown as { workstationType?: string }).workstationType ?? "computer")
                  .toString()
                  .toLowerCase()
                  .replace("_", " ");
                const bDate = b.booking_date ?? (b as unknown as { bookingDate?: string }).bookingDate;

                return (
                  <li key={b.id} className="flex items-center justify-between gap-3 py-3">
                    <div className="min-w-0">
                      <div className="truncate text-[14px] font-medium text-[var(--color-ink)]">
                        {userName}
                      </div>
                      <div className="truncate text-[12px] sm:text-[13px] capitalize text-[var(--color-muted)]">
                        {wsType} · {bDate}
                      </div>
                    </div>
                    <span className="shrink-0 rounded-full bg-[var(--color-surface-strong)] px-2.5 py-1 text-[10px] sm:text-[11px] font-semibold uppercase text-[var(--color-muted)]">
                      {b.status}
                    </span>
                  </li>
                );
              })}
            </ul>
          ) : (
            <p className="mt-4 text-[14px] text-[var(--color-body)]">No bookings yet.</p>
          )}
        </Card>
      </div>
    </div>
  );
}
