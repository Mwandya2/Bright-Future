"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { logout } from "@/app/actions/auth";
import { cn } from "@/components/ui";

export type NavItem = { href: string; label: string; icon: string };

export function DashboardShell({
  items,
  name,
  role,
  badge,
  children,
}: {
  items: NavItem[];
  name: string;
  role: string;
  badge: string;
  children: React.ReactNode;
}) {
  const pathname = usePathname();

  return (
    <div className="flex min-h-screen bg-[var(--color-canvas)]">
      {/* Sidebar */}
      <aside className="hidden w-64 shrink-0 flex-col border-r border-[var(--color-hairline)] bg-[var(--color-canvas-soft)] md:flex">
        <div className="flex h-16 items-center gap-2 border-b border-[var(--color-hairline)] px-6">
          <span className="grid h-7 w-7 place-items-center rounded-lg bg-[var(--color-ink)] text-white text-sm font-semibold">
            B
          </span>
          <span className="font-display text-[18px]">Bright Future</span>
        </div>
        <div className="px-4 pt-4">
          <span className="inline-flex items-center rounded-full bg-[var(--color-surface-strong)] px-2.5 py-1 text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--color-muted)]">
            {badge}
          </span>
        </div>
        <nav className="flex-1 space-y-1 p-4">
          {items.map((item) => {
            const active =
              pathname === item.href ||
              (item.href !== "/dashboard" &&
                item.href !== "/admin" &&
                pathname.startsWith(item.href));
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "flex items-center gap-3 rounded-lg px-3 py-2 text-[14px] font-medium transition",
                  active
                    ? "bg-[var(--color-ink)] text-white"
                    : "text-[var(--color-body-strong)] hover:bg-[var(--color-surface-strong)]",
                )}
              >
                <span className="w-5 text-center">{item.icon}</span>
                {item.label}
              </Link>
            );
          })}
        </nav>
        <div className="border-t border-[var(--color-hairline)] p-4">
          <div className="mb-3 px-1">
            <div className="text-[14px] font-medium text-[var(--color-ink)]">{name}</div>
            <div className="text-[12px] capitalize text-[var(--color-muted)]">{role}</div>
          </div>
          <form action={logout}>
            <button className="w-full rounded-lg border border-[var(--color-hairline-strong)] px-3 py-2 text-[14px] font-medium text-[var(--color-body-strong)] hover:bg-[var(--color-surface-strong)]">
              Sign out
            </button>
          </form>
        </div>
      </aside>

      {/* Main */}
      <div className="flex min-w-0 flex-1 flex-col">
        <header className="flex h-16 items-center justify-between border-b border-[var(--color-hairline)] bg-[var(--color-canvas)] px-5 md:px-8">
          <div className="flex items-center gap-3 md:hidden">
            <span className="grid h-7 w-7 place-items-center rounded-lg bg-[var(--color-ink)] text-white text-sm font-semibold">
              B
            </span>
            <span className="font-display text-[17px]">Bright Future</span>
          </div>
          <div className="hidden md:block" />
          <div className="flex items-center gap-3">
            <Link href="/" className="text-[14px] font-medium text-[var(--color-body-strong)] hover:text-[var(--color-ink)]">
              View site ↗
            </Link>
          </div>
        </header>

        {/* Mobile nav */}
        <div className="flex gap-1 overflow-x-auto border-b border-[var(--color-hairline)] bg-[var(--color-canvas-soft)] px-3 py-2 md:hidden">
          {items.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="whitespace-nowrap rounded-lg px-3 py-1.5 text-[13px] font-medium text-[var(--color-body-strong)]"
            >
              {item.icon} {item.label}
            </Link>
          ))}
        </div>

        <main className="flex-1 p-5 md:p-8">{children}</main>
      </div>
    </div>
  );
}
