import Link from "next/link";
import { getOptionalProfile } from "@/lib/auth";
import { ButtonLink } from "@/components/ui";
import { BrandLogo } from "@/components/brand-logo";
import { AccountMenu } from "@/components/account-menu";
import { MobileNav } from "@/components/mobile-nav";
import { isTheAdmin } from "@/lib/admin";

const links = [
  { href: "/courses", label: "Courses" },
  { href: "/#modules", label: "Ecosystem" },
  { href: "/#pricing", label: "Pricing" },
  { href: "/about", label: "About" },
  { href: "/contact", label: "Contact" },
];

export async function SiteNav() {
  const session = await getOptionalProfile();
  const user = session?.user ?? null;
  const profile = session?.profile ?? null;

  const displayName = profile?.full_name || user?.email || "";
  const isAdmin = user ? isTheAdmin(user.email, profile?.role) : false;

  return (
    <header className="sticky top-0 z-40 border-b border-[var(--color-hairline)] bg-[var(--color-canvas)]/85 backdrop-blur">
      <nav className="container-edge flex h-16 items-center justify-between">
        <BrandLogo href="/" size={34} gradient />

        {/* Desktop navigation links */}
        <div className="hidden items-center gap-7 md:flex">
          {links.map((l) => (
            <Link key={l.href} href={l.href} className="nav-link text-[15px] font-medium">
              {l.label}
            </Link>
          ))}
        </div>

        {/* Action buttons & Mobile drawer */}
        <div className="flex items-center gap-2 sm:gap-3">
          {user ? (
            <>
              {!isAdmin && (
                <Link
                  href="/dashboard/courses"
                  className="hidden px-2 text-[15px] font-medium text-[var(--color-body-strong)] hover:text-[var(--color-ink)] sm:block"
                >
                  My Courses
                </Link>
              )}
              <AccountMenu
                name={displayName}
                email={user.email ?? ""}
                avatarUrl={profile?.avatar_url ?? null}
                isAdmin={isAdmin}
              />
            </>
          ) : (
            <>
              <Link
                href="/login"
                className="hidden text-[15px] font-medium text-[var(--color-body-strong)] hover:text-[var(--color-ink)] sm:block px-3"
              >
                Sign in
              </Link>
              <ButtonLink href="/signup" variant="primary" className="hidden sm:inline-flex">
                Get started
              </ButtonLink>
            </>
          )}

          {/* Mobile hamburger navigation */}
          <MobileNav links={links} user={user} isAdmin={isAdmin} />
        </div>
      </nav>
    </header>
  );
}
