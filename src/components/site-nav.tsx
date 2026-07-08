import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { ButtonLink } from "@/components/ui";
import { BrandLogo } from "@/components/brand-logo";

const links = [
  { href: "/courses", label: "Courses" },
  { href: "/#modules", label: "Ecosystem" },
  { href: "/#pricing", label: "Pricing" },
  { href: "/about", label: "About" },
  { href: "/contact", label: "Contact" },
];

export async function SiteNav() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const meta = user?.user_metadata as { full_name?: string } | undefined;
  const display = meta?.full_name || user?.email || "";
  const firstName = (display.split(" ")[0] || "Account").split("@")[0];
  const initial = (firstName[0] || "A").toUpperCase();

  return (
    <header className="sticky top-0 z-40 border-b border-[var(--color-hairline)] bg-[var(--color-canvas)]/85 backdrop-blur">
      <nav className="container-edge flex h-16 items-center justify-between">
        <BrandLogo href="/" size={34} />

        <div className="hidden items-center gap-7 md:flex">
          {links.map((l) => (
            <Link
              key={l.href}
              href={l.href}
              className="text-[15px] font-medium text-[var(--color-body-strong)] hover:text-[var(--color-ink)]"
            >
              {l.label}
            </Link>
          ))}
        </div>

        <div className="flex items-center gap-2">
          {user ? (
            <>
              <Link
                href="/dashboard/courses"
                className="hidden px-2 text-[15px] font-medium text-[var(--color-body-strong)] hover:text-[var(--color-ink)] sm:block"
              >
                My Courses
              </Link>
              <Link
                href="/dashboard"
                className="flex items-center gap-2 rounded-full border border-[var(--color-hairline-strong)] bg-white py-1 pl-1 pr-3 transition hover:bg-[var(--color-surface-strong)]"
              >
                <span className="chip-mint grid h-7 w-7 place-items-center rounded-full text-[13px] font-semibold text-[var(--color-ink)]">
                  {initial}
                </span>
                <span className="max-w-[8rem] truncate text-[14px] font-medium text-[var(--color-ink)]">
                  {firstName}
                </span>
              </Link>
            </>
          ) : (
            <>
              <Link
                href="/login"
                className="hidden text-[15px] font-medium text-[var(--color-body-strong)] hover:text-[var(--color-ink)] sm:block px-3"
              >
                Sign in
              </Link>
              <ButtonLink href="/signup" variant="primary">
                Get started
              </ButtonLink>
            </>
          )}
        </div>
      </nav>
    </header>
  );
}
