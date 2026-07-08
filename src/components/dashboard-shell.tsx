"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useState } from "react";
import { logout } from "@/app/actions/auth";
import { cn } from "@/components/ui";
import { BrandLogo } from "@/components/brand-logo";

export type NavItem = { href: string; label: string; icon: string };

function isActivePath(pathname: string, href: string) {
  return (
    pathname === href ||
    (href !== "/dashboard" && href !== "/admin" && pathname.startsWith(href))
  );
}

function SidebarBody({
  items,
  name,
  role,
  badge,
  onNavigate,
}: {
  items: NavItem[];
  name: string;
  role: string;
  badge: string;
  onNavigate?: () => void;
}) {
  const pathname = usePathname();
  return (
    <div className="flex h-full flex-col bg-[var(--color-surface-dark)]">
      <div className="flex h-16 items-center border-b border-white/10 px-6">
        <BrandLogo href="/" size={32} wordmarkSize="text-[18px]" textClass="text-white" />
      </div>

      <div className="px-4 pt-4">
        <span className="inline-flex items-center gap-1.5 rounded-full bg-white/10 px-2.5 py-1 text-[11px] font-semibold uppercase tracking-[0.08em] text-white/80">
          {badge}
        </span>
      </div>

      <nav className="flex-1 space-y-1 overflow-y-auto p-4">
        {items.map((item) => {
          const active = isActivePath(pathname, item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={onNavigate}
              className={cn(
                "flex items-center gap-3 rounded-xl px-3 py-2.5 text-[14px] font-medium transition",
                active
                  ? "bg-white text-[var(--color-ink)] shadow-sm"
                  : "text-white/65 hover:bg-white/10 hover:text-white",
              )}
            >
              <span
                className={cn(
                  "grid h-6 w-6 place-items-center rounded-md text-[13px]",
                  active ? "bg-[var(--color-ink)] text-white" : "bg-white/10",
                )}
              >
                {item.icon}
              </span>
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="border-t border-white/10 p-4">
        <div className="mb-3 flex items-center gap-3 px-1">
          <span className="chip-mint grid h-9 w-9 shrink-0 place-items-center rounded-full text-[14px] font-semibold text-[var(--color-ink)]">
            {(name || "U").slice(0, 1).toUpperCase()}
          </span>
          <div className="min-w-0">
            <div className="truncate text-[14px] font-medium text-white">{name}</div>
            <div className="text-[12px] capitalize text-white/50">{role}</div>
          </div>
        </div>
        <form action={logout}>
          <button className="w-full rounded-xl border border-white/15 px-3 py-2 text-[14px] font-medium text-white/85 transition hover:bg-white/10">
            Sign out
          </button>
        </form>
      </div>
    </div>
  );
}

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
  const [open, setOpen] = useState(false);

  return (
    <div className="dash-bg flex min-h-screen">
      {/* Desktop sidebar */}
      <aside className="hidden w-64 shrink-0 md:block">
        <div className="sticky top-0 h-screen">
          <SidebarBody items={items} name={name} role={role} badge={badge} />
        </div>
      </aside>

      {/* Mobile drawer */}
      {open && (
        <div className="fixed inset-0 z-50 md:hidden">
          <div
            className="absolute inset-0 bg-black/45 backdrop-blur-sm"
            onClick={() => setOpen(false)}
          />
          <aside className="absolute left-0 top-0 h-full w-72 max-w-[82vw] shadow-2xl">
            <SidebarBody
              items={items}
              name={name}
              role={role}
              badge={badge}
              onNavigate={() => setOpen(false)}
            />
          </aside>
        </div>
      )}

      {/* Main column */}
      <div className="flex min-w-0 flex-1 flex-col">
        <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-[var(--color-hairline)] bg-[var(--color-canvas)]/80 px-4 backdrop-blur md:px-8">
          <div className="flex items-center gap-3">
            <button
              onClick={() => setOpen(true)}
              aria-label="Open menu"
              className="grid h-9 w-9 place-items-center rounded-lg border border-[var(--color-hairline-strong)] bg-white text-[var(--color-ink)] md:hidden"
            >
              <span className="text-[16px] leading-none">☰</span>
            </button>
            <span className="md:hidden">
              <BrandLogo href="/" size={28} wordmarkSize="text-[16px]" />
            </span>
          </div>
          <Link
            href="/"
            className="rounded-full border border-[var(--color-hairline-strong)] bg-white px-3.5 py-1.5 text-[13px] font-medium text-[var(--color-body-strong)] transition hover:bg-[var(--color-surface-strong)]"
          >
            View site ↗
          </Link>
        </header>

        <main className="flex-1 p-5 md:p-8">{children}</main>
      </div>
    </div>
  );
}
