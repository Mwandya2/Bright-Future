"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import { ChevronDown, LayoutGrid, BookOpen, Shield, LogOut } from "lucide-react";
import { logout } from "@/app/actions/auth";

export function AccountMenu({
  name,
  email,
  avatarUrl,
  isAdmin,
}: {
  name: string;
  email: string;
  avatarUrl: string | null;
  isAdmin: boolean;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const onClick = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    document.addEventListener("mousedown", onClick);
    return () => document.removeEventListener("mousedown", onClick);
  }, []);

  const first = (name || "Account").split(" ")[0];
  const initial = (first[0] || "A").toUpperCase();

  return (
    <div className="relative" ref={ref}>
      <button
        onClick={() => setOpen((v) => !v)}
        className="flex items-center gap-2 rounded-full border border-[var(--color-hairline-strong)] bg-white py-1 pl-1 pr-2.5 transition hover:bg-[var(--color-canvas-soft)]"
        aria-haspopup="menu"
        aria-expanded={open}
      >
        <span className="grid h-7 w-7 place-items-center overflow-hidden rounded-full chip-lavender text-[13px] font-semibold text-white">
          {avatarUrl ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={avatarUrl} alt="" className="h-full w-full object-cover" />
          ) : (
            initial
          )}
        </span>
        <span className="max-w-[8rem] truncate text-[14px] font-medium text-[var(--color-ink)]">
          {first}
        </span>
        <ChevronDown className="h-4 w-4 text-[var(--color-muted)]" />
      </button>

      {open && (
        <div
          role="menu"
          className="absolute right-0 z-50 mt-2 w-60 overflow-hidden rounded-xl border border-[var(--color-hairline)] bg-white p-1.5 shadow-[0_8px_24px_rgba(0,55,112,0.12)]"
        >
          <div className="px-3 py-2">
            <div className="truncate text-[14px] font-medium text-[var(--color-ink)]">
              {name || "My account"}
            </div>
            {email && (
              <div className="truncate text-[12px] text-[var(--color-muted)]">{email}</div>
            )}
          </div>
          <div className="my-1 h-px bg-[var(--color-hairline)]" />

          <MenuLink href="/dashboard" icon={<LayoutGrid className="h-4 w-4" />} onClick={() => setOpen(false)}>
            My Account
          </MenuLink>
          <MenuLink href="/dashboard/courses" icon={<BookOpen className="h-4 w-4" />} onClick={() => setOpen(false)}>
            My Courses
          </MenuLink>
          {isAdmin && (
            <MenuLink href="/admin" icon={<Shield className="h-4 w-4" />} onClick={() => setOpen(false)}>
              Admin Dashboard
            </MenuLink>
          )}

          <div className="my-1 h-px bg-[var(--color-hairline)]" />
          <form action={logout}>
            <button
              type="submit"
              className="flex w-full items-center gap-2.5 rounded-lg px-3 py-2 text-[14px] font-medium text-[var(--color-error)] transition hover:bg-[color-mix(in_srgb,var(--color-error)_8%,transparent)]"
            >
              <LogOut className="h-4 w-4" />
              Sign out
            </button>
          </form>
        </div>
      )}
    </div>
  );
}

function MenuLink({
  href,
  icon,
  children,
  onClick,
}: {
  href: string;
  icon: React.ReactNode;
  children: React.ReactNode;
  onClick: () => void;
}) {
  return (
    <Link
      href={href}
      onClick={onClick}
      className="flex items-center gap-2.5 rounded-lg px-3 py-2 text-[14px] font-medium text-[var(--color-body-strong)] transition hover:bg-[var(--color-canvas-soft)]"
    >
      {icon}
      {children}
    </Link>
  );
}
