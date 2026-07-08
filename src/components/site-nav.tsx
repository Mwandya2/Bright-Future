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
            <ButtonLink href="/dashboard" variant="primary">
              Dashboard
            </ButtonLink>
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
