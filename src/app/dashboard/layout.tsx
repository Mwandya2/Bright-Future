import { redirect } from "next/navigation";
import {
  LayoutDashboard,
  BookOpen,
  MonitorSmartphone,
  Printer,
} from "lucide-react";
import { requireProfile } from "@/lib/auth";
import { isTheAdmin } from "@/lib/admin";
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
  const { user, profile } = await requireProfile();

  // The admin is an overseer only — no member actions (enrol, book, order).
  // Bounce them to the admin dashboard.
  if (isTheAdmin(user.email, profile.role)) {
    redirect("/admin");
  }

  return (
    <DashboardShell
      items={items}
      name={profile.full_name ?? "Member"}
      role={profile.role}
      badge="My Hub"
    >
      {children}
    </DashboardShell>
  );
}
