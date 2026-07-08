import {
  LayoutDashboard,
  BookOpen,
  MonitorSmartphone,
  Printer,
  Shield,
} from "lucide-react";
import { requireProfile } from "@/lib/auth";
import { DashboardShell, type NavItem } from "@/components/dashboard-shell";

const items: NavItem[] = [
  { href: "/dashboard", label: "Overview", icon: <LayoutDashboard /> },
  { href: "/dashboard/courses", label: "My Courses", icon: <BookOpen /> },
  { href: "/dashboard/bookings", label: "Lab Bookings", icon: <MonitorSmartphone /> },
  { href: "/dashboard/printing", label: "Printing", icon: <Printer /> },
];

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { profile } = await requireProfile();

  const nav = [...items];
  if (profile.role === "admin") {
    nav.push({ href: "/admin", label: "Admin Panel", icon: <Shield /> });
  }

  return (
    <DashboardShell
      items={nav}
      name={profile.full_name ?? "Member"}
      role={profile.role}
      badge="My Hub"
    >
      {children}
    </DashboardShell>
  );
}
