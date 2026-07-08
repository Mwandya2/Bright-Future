import { BrandLogo } from "@/components/brand-logo";

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
          <BrandLogo href="/" size={34} />
        </div>
      </header>
      <main className="relative z-10 flex flex-1 items-center justify-center px-5 py-12">
        {children}
      </main>
    </div>
  );
}
