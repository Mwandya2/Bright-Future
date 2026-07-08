import { createAdminClient } from "@/lib/supabase/admin";
import { Card } from "@/components/ui";

export const metadata = { title: "Admin Overview" };

export default async function AdminHome() {
  const supabase = createAdminClient();

  const [users, courses, bookings, orders, ordersData] = await Promise.all([
    supabase.from("profiles").select("*", { count: "exact", head: true }),
    supabase.from("courses").select("*", { count: "exact", head: true }),
    supabase.from("lab_bookings").select("*", { count: "exact", head: true }),
    supabase.from("print_orders").select("*", { count: "exact", head: true }),
    supabase.from("print_orders").select("estimated_price"),
  ]);

  const revenue = (ordersData.data ?? []).reduce(
    (sum, o: { estimated_price: number | null }) => sum + (o.estimated_price ?? 0),
    0,
  );

  const { data: recentBookings } = await supabase
    .from("lab_bookings")
    .select("*, profile:profiles(full_name, email)")
    .order("created_at", { ascending: false })
    .limit(5);

  const stats = [
    { label: "Total users", value: users.count ?? 0, icon: "◉", chip: "chip-mint" },
    { label: "Courses", value: courses.count ?? 0, icon: "▦", chip: "chip-sky" },
    { label: "Lab bookings", value: bookings.count ?? 0, icon: "▤", chip: "chip-lavender" },
    { label: "Print orders", value: orders.count ?? 0, icon: "◨", chip: "chip-peach" },
  ];

  return (
    <div className="mx-auto max-w-6xl">
      <h1 className="font-display text-3xl md:text-4xl">Admin overview</h1>
      <p className="mt-2 text-[15px] text-[var(--color-body)]">
        Platform activity across Bright Future Digital Hub.
      </p>

      <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((s) => (
          <Card key={s.label} className="relative overflow-hidden p-6">
            <div className={`absolute inset-x-0 top-0 h-1 ${s.chip}`} />
            <div className="flex items-start justify-between">
              <div>
                <div className="font-display tnum text-4xl">{s.value}</div>
                <div className="mt-1 text-[14px] text-[var(--color-muted)]">{s.label}</div>
              </div>
              <span className={`grid h-10 w-10 place-items-center rounded-xl ${s.chip} text-[16px] text-[var(--color-ink)]`}>
                {s.icon}
              </span>
            </div>
          </Card>
        ))}
      </div>

      <div className="mt-6 grid gap-6 lg:grid-cols-[1fr_1.4fr]">
        <Card className="bg-[var(--color-surface-dark)] p-6 text-white">
          <div className="text-[13px] uppercase tracking-[0.08em] text-[var(--color-on-dark-soft)]">
            Estimated printing revenue
          </div>
          <div className="font-display tnum mt-3 text-4xl text-white">
            TZS {revenue.toLocaleString()}
          </div>
          <p className="mt-2 text-[13px] text-[var(--color-on-dark-soft)]">
            Sum of print-order estimates across the platform.
          </p>
        </Card>

        <Card className="p-6">
          <h2 className="text-[18px] font-medium text-[var(--color-ink)]">Recent bookings</h2>
          {recentBookings && recentBookings.length > 0 ? (
            <ul className="mt-4 divide-y divide-[var(--color-hairline)]">
              {recentBookings.map((b) => (
                <li key={b.id} className="flex items-center justify-between py-3">
                  <div>
                    <div className="text-[14px] font-medium text-[var(--color-ink)]">
                      {b.profile?.full_name ?? b.profile?.email ?? "User"}
                    </div>
                    <div className="text-[13px] capitalize text-[var(--color-muted)]">
                      {b.workstation_type.replace("_", " ")} · {b.booking_date}
                    </div>
                  </div>
                  <span className="rounded-full bg-[var(--color-surface-strong)] px-2.5 py-1 text-[11px] font-semibold uppercase text-[var(--color-muted)]">
                    {b.status}
                  </span>
                </li>
              ))}
            </ul>
          ) : (
            <p className="mt-4 text-[14px] text-[var(--color-body)]">No bookings yet.</p>
          )}
        </Card>
      </div>
    </div>
  );
}
