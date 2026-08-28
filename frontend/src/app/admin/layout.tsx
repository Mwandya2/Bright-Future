import {
  LayoutDashboard,
  BookOpen,
  MonitorSmartphone,
  Printer,
  Mail,
  Users,
  ArrowLeft,
} from "lucide-react";
import { requireProfile } from "@/lib/auth";
import { DashboardShell, type NavItem } from "@/components/dashboard-shell";

const items: NavItem[] = [
  { href: "/admin", label: "Overview", icon: <LayoutDashboard /> },
  { href: "/admin/courses", label: "Courses", icon: <BookOpen /> },
  { href: "/admin/bookings", label: "Lab Bookings", icon: <MonitorSmartphone /> },
  { href: "/admin/orders", label: "Print Orders", icon: <Printer /> },
  { href: "/admin/messages", label: "Messages", icon: <Mail /> },
  { href: "/admin/users", label: "Users", icon: <Users /> },
  { href: "/dashboard", label: "My Hub", icon: <ArrowLeft /> },
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
