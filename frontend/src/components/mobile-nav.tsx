"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Menu, X, BookOpen, Layers, DollarSign, Info, Mail, LogIn, ArrowRight } from "lucide-react";
import { BrandLogo } from "@/components/brand-logo";

interface MobileNavProps {
  links: Array<{ href: string; label: string }>;
  user: { id: string; email?: string } | null;
  isAdmin: boolean;
}

export function MobileNav({ links, user, isAdmin }: MobileNavProps) {
  const [isOpen, setIsOpen] = useState(false);
  const pathname = usePathname();

  // Close drawer when pathname changes
  useEffect(() => {
    setIsOpen(false);
  }, [pathname]);

  // Lock body scroll when drawer is open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
    return () => {
      document.body.style.overflow = "";
    };
  }, [isOpen]);

  const getIcon = (href: string) => {
    if (href.includes("courses")) return <BookOpen className="h-5 w-5" />;
    if (href.includes("modules")) return <Layers className="h-5 w-5" />;
    if (href.includes("pricing")) return <DollarSign className="h-5 w-5" />;
    if (href.includes("about")) return <Info className="h-5 w-5" />;
    if (href.includes("contact")) return <Mail className="h-5 w-5" />;
    return <ArrowRight className="h-5 w-5" />;
  };

  return (
    <div className="md:hidden">
      <button
        type="button"
        onClick={() => setIsOpen(!isOpen)}
        className="flex h-10 w-10 items-center justify-center rounded-xl border border-[var(--color-hairline)] bg-[var(--color-canvas)] text-[var(--color-ink)] hover:bg-[var(--color-canvas-soft)] transition focus:outline-none"
        aria-label={isOpen ? "Close menu" : "Open menu"}
        aria-expanded={isOpen}
      >
        {isOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
      </button>

      {/* Backdrop */}
      {isOpen && (
        <div
          className="fixed inset-0 top-16 z-50 bg-black/40 backdrop-blur-sm transition-opacity"
          onClick={() => setIsOpen(false)}
        />
      )}

      {/* Drawer Menu */}
      <div
        className={`fixed inset-x-0 top-16 z-50 max-h-[calc(100vh-4rem)] overflow-y-auto border-b border-[var(--color-hairline)] bg-[var(--color-canvas)] p-6 shadow-2xl transition-all duration-300 ease-out ${
          isOpen ? "translate-y-0 opacity-100" : "-translate-y-4 opacity-0 pointer-events-none"
        }`}
      >
        <div className="flex flex-col gap-2">
          {links.map((l) => (
            <Link
              key={l.href}
              href={l.href}
              className="flex items-center gap-3 rounded-xl p-3.5 text-[16px] font-medium text-[var(--color-ink)] hover:bg-[var(--color-canvas-soft)] transition"
            >
              <span className="text-[var(--color-primary)]">{getIcon(l.href)}</span>
              {l.label}
            </Link>
          ))}
        </div>

        <div className="mt-6 border-t border-[var(--color-hairline)] pt-6 flex flex-col gap-3">
          {user ? (
            <>
              <Link
                href={isAdmin ? "/admin" : "/dashboard"}
                className="flex h-12 w-full items-center justify-center rounded-full bg-[var(--color-primary)] px-6 text-[15px] font-medium text-white shadow-sm hover:bg-[var(--color-primary-press)] transition"
              >
                {isAdmin ? "Admin Dashboard" : "Go to Dashboard"}
              </Link>
            </>
          ) : (
            <>
              <Link
                href="/login"
                className="flex h-12 w-full items-center justify-center gap-2 rounded-full border border-[var(--color-hairline)] bg-[var(--color-canvas-soft)] px-6 text-[15px] font-medium text-[var(--color-ink)] hover:bg-[var(--color-hairline)] transition"
              >
                <LogIn className="h-4 w-4" /> Sign in
              </Link>
              <Link
                href="/signup"
                className="flex h-12 w-full items-center justify-center rounded-full bg-[var(--color-primary)] px-6 text-[15px] font-medium text-white shadow-sm hover:bg-[var(--color-primary-press)] transition"
              >
                Get started free
              </Link>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
