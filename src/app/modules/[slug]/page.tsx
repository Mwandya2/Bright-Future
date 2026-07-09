import { notFound } from "next/navigation";
import type { Metadata } from "next";
import { SiteNav } from "@/components/site-nav";
import { SiteFooter } from "@/components/site-footer";
import { GsapReveal } from "@/components/gsap-reveal";
import { Card, Badge, ButtonLink, SectionLabel } from "@/components/ui";
import { MODULES, getModule } from "@/lib/modules";

export function generateStaticParams() {
  return MODULES.map((m) => ({ slug: m.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const m = getModule(slug);
  return m ? { title: m.title, description: m.tagline } : { title: "Module" };
}

export default async function ModulePage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const m = getModule(slug);
  if (!m) notFound();

  return (
    <div className="flex min-h-screen flex-col">
      <GsapReveal />
      <SiteNav />
      <main className="flex-1">
        {/* Hero */}
        <section className="relative overflow-hidden border-b border-[var(--color-hairline)]">
          <div className="mesh-hero" style={{ height: 440 }} />
          <div className="container-edge relative z-10 py-20">
            <div className="flex items-center gap-3">
              <Badge>{m.label}</Badge>
              {m.status === "coming-soon" && (
                <span className="rounded-full bg-[var(--color-surface-strong)] px-2.5 py-1 text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--color-muted)]">
                  Coming soon
                </span>
              )}
            </div>
            <h1
              data-hero
              className="font-display mt-5 max-w-3xl text-4xl md:text-6xl"
              style={{ fontWeight: 800 }}
            >
              {m.title}
            </h1>
            <p data-hero className="mt-5 max-w-2xl text-lg text-[var(--color-body)]">
              {m.overview}
            </p>
            <div data-hero className="mt-8 flex flex-wrap gap-3">
              {m.status === "live" && m.ctaHref ? (
                <ButtonLink href={m.ctaHref} variant="primary" className="h-11 px-6">
                  {m.ctaLabel ?? "Get started"}
                </ButtonLink>
              ) : (
                <ButtonLink href="/signup" variant="primary" className="h-11 px-6">
                  Join the waitlist
                </ButtonLink>
              )}
              <ButtonLink href="/#modules" variant="outline" className="h-11 px-6">
                All modules
              </ButtonLink>
            </div>
          </div>
        </section>

        {/* Features */}
        <section className="section">
          <div className="container-edge">
            <SectionLabel>What&apos;s inside</SectionLabel>
            <h2 className="font-display mt-3 text-3xl md:text-4xl">
              {m.tagline}
            </h2>
            <div className="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {m.features.map((f) => (
                <Card key={f.title} className="reveal p-6">
                  <h3 className="text-[17px] font-medium text-[var(--color-ink)]">
                    {f.title}
                  </h3>
                  <p className="mt-1.5 text-[14px] text-[var(--color-body)]">{f.body}</p>
                </Card>
              ))}
            </div>
          </div>
        </section>

        {/* CTA */}
        <section className="section border-t border-[var(--color-hairline)] bg-[var(--color-canvas-cream)]">
          <div className="container-edge text-center">
            <h2 className="font-display mx-auto max-w-2xl text-3xl md:text-4xl">
              {m.status === "live"
                ? "Ready to get started?"
                : "Be first when this launches"}
            </h2>
            <div className="mt-8 flex justify-center gap-3">
              {m.status === "live" && m.ctaHref ? (
                <ButtonLink href={m.ctaHref} variant="primary" className="h-11 px-7">
                  {m.ctaLabel ?? "Get started"}
                </ButtonLink>
              ) : (
                <ButtonLink href="/signup" variant="primary" className="h-11 px-7">
                  Create a free account
                </ButtonLink>
              )}
              <ButtonLink href="/contact" variant="outline" className="h-11 px-7">
                Contact us
              </ButtonLink>
            </div>
          </div>
        </section>
      </main>
      <SiteFooter />
    </div>
  );
}
