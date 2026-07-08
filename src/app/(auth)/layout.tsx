import Link from "next/link";

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="relative flex min-h-screen flex-col overflow-hidden">
      <div className="orb orb-mint" style={{ width: 380, height: 380, top: -100, left: -80 }} />
      <div className="orb orb-lavender" style={{ width: 340, height: 340, bottom: -120, right: -60 }} />
      <header className="relative z-10">
        <div className="container-edge flex h-16 items-center">
          <Link href="/" className="flex items-center gap-2">
            <span className="grid h-7 w-7 place-items-center rounded-lg bg-[var(--color-ink)] text-white text-sm font-semibold">
              B
            </span>
            <span className="font-display text-[19px]">Bright Future</span>
          </Link>
        </div>
      </header>
      <main className="relative z-10 flex flex-1 items-center justify-center px-5 py-12">
        {children}
      </main>
    </div>
  );
}
