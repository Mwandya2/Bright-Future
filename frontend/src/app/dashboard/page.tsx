import Link from "next/link";
import { BookOpen, MonitorSmartphone, Printer } from "lucide-react";
import { requireProfile } from "@/lib/auth";
import { apiClient } from "@/lib/api-client";
import { Card, ButtonLink } from "@/components/ui";
import type { Enrollment, LabBooking, PrintOrder } from "@/lib/types";

export const metadata = { title: "My Account" };

export default async function DashboardHome() {
  const { profile } = await requireProfile();

  const [enrollmentsRes, bookingsRes, ordersRes] = await Promise.all([
    apiClient.get<Enrollment[]>("/enrollments/my"),
    apiClient.get<LabBooking[]>("/bookings/my"),
    apiClient.get<PrintOrder[]>("/orders/my"),
  ]);

  const enrollments = enrollmentsRes.data ?? [];
  const bookings = bookingsRes.data ?? [];
  const orders = ordersRes.data ?? [];

  const activeBookings = bookings.filter((b) => String(b.status).toLowerCase() !== "cancelled");
  const upcoming = activeBookings.slice(0, 3);

  const stats = [
    { label: "Active courses", value: enrollments.length, href: "/dashboard/courses" },
    { label: "Lab bookings", value: activeBookings.length, href: "/dashboard/bookings" },
    { label: "Print orders", value: orders.length, href: "/dashboard/printing" },
  ];

  return (
    <div className="mx-auto max-w-5xl">
      <h1 className="font-display text-2xl sm:text-3xl md:text-4xl">
        Welcome back, {(profile.full_name ?? "there").split(" ")[0]}
      </h1>
      <p className="mt-2 text-[14px] sm:text-[15px] text-[var(--color-body)]">
        Here&apos;s a snapshot of your Bright Future activity.
      </p>

      <div className="mt-6 sm:mt-8 grid gap-4 grid-cols-1 sm:grid-cols-3">
        {stats.map((s) => (
          <Link key={s.label} href={s.href}>
            <Card className="p-5 sm:p-6 transition hover:shadow-[0_4px_20px_rgba(0,0,0,0.05)]">
              <div className="font-display text-3xl sm:text-4xl">{s.value}</div>
              <div className="mt-1 text-[13px] sm:text-[14px] text-[var(--color-muted)]">{s.label}</div>
            </Card>
          </Link>
        ))}
      </div>

      <div className="mt-6 sm:mt-8 grid gap-6 grid-cols-1 lg:grid-cols-2">
        <Card className="p-5 sm:p-6">
          <h2 className="text-[17px] sm:text-[18px] font-medium text-[var(--color-ink)]">
            Upcoming lab bookings
          </h2>
          {upcoming.length > 0 ? (
            <ul className="mt-4 divide-y divide-[var(--color-hairline)]">
              {upcoming.map((b) => {
                const wsType = (b.workstation_type ?? (b as unknown as { workstationType?: string }).workstationType ?? "computer")
                  .toString()
                  .toLowerCase()
                  .replace("_", " ");
                const bDate = b.booking_date ?? (b as unknown as { bookingDate?: string }).bookingDate;
                const bTime = b.start_time ?? (b as unknown as { startTime?: string }).startTime;
                const bHours = b.duration_hours ?? (b as unknown as { durationHours?: number }).durationHours ?? 1;

                return (
                  <li key={b.id} className="flex items-center justify-between py-3 gap-2">
                    <div className="min-w-0 flex-1">
                      <div className="text-[14px] sm:text-[15px] font-medium capitalize text-[var(--color-ink)] truncate">
                        {wsType}
                      </div>
                      <div className="text-[12px] sm:text-[13px] text-[var(--color-muted)]">
                        {bDate} · {bTime} · {bHours}h
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
            <p className="mt-4 text-[14px] text-[var(--color-body)]">
              No upcoming bookings.{" "}
              <Link href="/dashboard/bookings" className="font-medium text-[var(--color-ink)] underline">
                Book a workstation
              </Link>
            </p>
          )}
        </Card>

        <Card className="p-5 sm:p-6">
          <h2 className="text-[17px] sm:text-[18px] font-medium text-[var(--color-ink)]">Quick actions</h2>
          <div className="mt-4 grid gap-3">
            <ButtonLink href="/courses" variant="outline" className="w-full justify-start">
              <BookOpen className="h-4 w-4" /> Browse courses
            </ButtonLink>
            <ButtonLink href="/dashboard/bookings" variant="outline" className="w-full justify-start">
              <MonitorSmartphone className="h-4 w-4" /> Book the computer lab
            </ButtonLink>
            <ButtonLink href="/dashboard/printing" variant="outline" className="w-full justify-start">
              <Printer className="h-4 w-4" /> Request digital printing
            </ButtonLink>
          </div>
        </Card>
      </div>
    </div>
  );
}
