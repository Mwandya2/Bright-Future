import Link from "next/link";
import { BookOpen, MonitorSmartphone, Printer } from "lucide-react";
import { requireProfile } from "@/lib/auth";
import { createClient } from "@/lib/supabase/server";
import { Card, ButtonLink } from "@/components/ui";

export const metadata = { title: "My Account" };

export default async function DashboardHome() {
  const { user, profile } = await requireProfile();
  const supabase = await createClient();

  const [{ count: enrollments }, { count: bookings }, { count: orders }] =
    await Promise.all([
      supabase.from("enrollments").select("*", { count: "exact", head: true }).eq("user_id", user.id),
      supabase.from("lab_bookings").select("*", { count: "exact", head: true }).eq("user_id", user.id).neq("status", "cancelled"),
      supabase.from("print_orders").select("*", { count: "exact", head: true }).eq("user_id", user.id),
    ]);

  const { data: upcoming } = await supabase
    .from("lab_bookings")
    .select("*")
    .eq("user_id", user.id)
    .neq("status", "cancelled")
    .order("booking_date", { ascending: true })
    .limit(3);

  const stats = [
    { label: "Active courses", value: enrollments ?? 0, href: "/dashboard/courses" },
    { label: "Lab bookings", value: bookings ?? 0, href: "/dashboard/bookings" },
    { label: "Print orders", value: orders ?? 0, href: "/dashboard/printing" },
  ];

  return (
    <div className="mx-auto max-w-5xl">
      <h1 className="font-display text-3xl md:text-4xl">
        Welcome back, {(profile.full_name ?? "there").split(" ")[0]}
      </h1>
      <p className="mt-2 text-[15px] text-[var(--color-body)]">
        Here&apos;s a snapshot of your Bright Future activity.
      </p>

      <div className="mt-8 grid gap-4 sm:grid-cols-3">
        {stats.map((s) => (
          <Link key={s.label} href={s.href}>
            <Card className="p-6 transition hover:shadow-[0_4px_20px_rgba(0,0,0,0.05)]">
              <div className="font-display text-4xl">{s.value}</div>
              <div className="mt-1 text-[14px] text-[var(--color-muted)]">{s.label}</div>
            </Card>
          </Link>
        ))}
      </div>

      <div className="mt-8 grid gap-6 lg:grid-cols-2">
        <Card className="p-6">
          <h2 className="text-[18px] font-medium text-[var(--color-ink)]">
            Upcoming lab bookings
          </h2>
          {upcoming && upcoming.length > 0 ? (
            <ul className="mt-4 divide-y divide-[var(--color-hairline)]">
              {upcoming.map((b) => (
                <li key={b.id} className="flex items-center justify-between py-3">
                  <div>
                    <div className="text-[15px] font-medium capitalize text-[var(--color-ink)]">
                      {b.workstation_type.replace("_", " ")}
                    </div>
                    <div className="text-[13px] text-[var(--color-muted)]">
                      {b.booking_date} · {b.start_time} · {b.duration_hours}h
                    </div>
                  </div>
                  <span className="rounded-full bg-[var(--color-surface-strong)] px-2.5 py-1 text-[11px] font-semibold uppercase text-[var(--color-muted)]">
                    {b.status}
                  </span>
                </li>
              ))}
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

        <Card className="p-6">
          <h2 className="text-[18px] font-medium text-[var(--color-ink)]">Quick actions</h2>
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
