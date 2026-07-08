import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { ButtonLink } from "@/components/ui";
import { BrandLogo } from "@/components/brand-logo";
import { AccountMenu } from "@/components/account-menu";
import { isTheAdmin } from "@/lib/admin";

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

  type NavProfile = {
    full_name: string | null;
    avatar_url: string | null;
    role: string | null;
  };
  let profile: NavProfile | null = null;

  if (user) {
    const { data } = await supabase
      .from("profiles")
      .select("full_name, avatar_url, role")
      .eq("id", user.id)
      .single();
    profile = (data as NavProfile) ?? null;
  }

  const displayName =
    profile?.full_name ||
    (user?.user_metadata as { full_name?: string } | undefined)?.full_name ||
    user?.email ||
    "";
  const isAdmin = isTheAdmin(user?.email, profile?.role);

  return (
    <header className="sticky top-0 z-40 border-b border-[var(--color-hairline)] bg-[var(--color-canvas)]/85 backdrop-blur">
      <nav className="container-edge flex h-16 items-center justify-between">
        <BrandLogo href="/" size={34} gradient />

        <div className="hidden items-center gap-7 md:flex">
          {links.map((l) => (
            <Link key={l.href} href={l.href} className="nav-link text-[15px] font-medium">
              {l.label}
            </Link>
          ))}
        </div>

        <div className="flex items-center gap-3">
          {user ? (
            <>
              <Link
                href="/dashboard/courses"
                className="hidden px-1 text-[15px] font-medium text-[var(--color-body-strong)] hover:text-[var(--color-ink)] sm:block"
              >
                My Courses
              </Link>
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
