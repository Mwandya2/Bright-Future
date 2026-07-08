import { requireProfile } from "@/lib/auth";
import { DashboardShell, type NavItem } from "@/components/dashboard-shell";

const items: NavItem[] = [
  { href: "/admin", label: "Overview", icon: "◆" },
  { href: "/admin/courses", label: "Courses", icon: "▦" },
  { href: "/admin/bookings", label: "Lab Bookings", icon: "▤" },
  { href: "/admin/orders", label: "Print Orders", icon: "◨" },
  { href: "/admin/messages", label: "Messages", icon: "✉" },
  { href: "/admin/users", label: "Users", icon: "◉" },
  { href: "/dashboard", label: "My Hub", icon: "↩" },
];

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { profile } = await requireProfile({ admin: true });

  return (
    <DashboardShell
      items={items}
      name={profile.full_name ?? "Administrator"}
      role={profile.role}
      badge="Admin"
    >
      {children}
    </DashboardShell>
  );
}
