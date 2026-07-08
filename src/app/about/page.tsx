import { SiteNav } from "@/components/site-nav";
import { SiteFooter } from "@/components/site-footer";
import { GsapReveal } from "@/components/gsap-reveal";
import { Card, ButtonLink, SectionLabel } from "@/components/ui";

export const metadata = { title: "About" };

const values = [
  ["Skills first", "We put practical, job-ready digital skills at the centre of everything."],
  ["Access for all", "Affordable training, lab access, and services for students and SMEs alike."],
  ["Community", "A hub where learners, entrepreneurs, and mentors grow together."],
  ["Innovation", "Smart tools — AI assistance, QR attendance, digital verification — built in."],
];

const positioning = [
  "A Leading Digital Empowerment Platform",
  "A Youth Innovation Ecosystem",
  "A Regional ICT Skills Development Center",
  "A Smart Digital Services Marketplace",
  "A Bridge Between Education and Employment",
];

export default function AboutPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <GsapReveal />
      <SiteNav />
      <main className="flex-1">
        <section className="relative overflow-hidden border-b border-[var(--color-hairline)]">
          <div className="orb orb-lavender" style={{ width: 360, height: 360, top: -120, right: -40 }} />
          <div className="container-edge relative z-10 py-24">
            <SectionLabel>About Bright Future</SectionLabel>
            <h1 data-hero className="font-display mt-3 max-w-3xl text-4xl md:text-6xl">
              More than an app — a digital empowerment ecosystem
            </h1>
            <p data-hero className="mt-6 max-w-2xl text-lg text-[var(--color-body)]">
              Bright Future transforms how students, entrepreneurs, professionals,
              and communities access ICT education, digital services, business
              support, and innovation opportunities.
            </p>
          </div>
        </section>

        <section className="section">
          <div className="container-edge">
            <SectionLabel>Our values</SectionLabel>
            <h2 className="font-display mt-3 text-3xl md:text-4xl">What we stand for</h2>
            <div className="mt-10 grid gap-4 sm:grid-cols-2">
              {values.map(([t, b]) => (
                <Card key={t} className="reveal p-7">
                  <h3 className="text-[18px] font-medium text-[var(--color-ink)]">{t}</h3>
                  <p className="mt-2 text-[15px] text-[var(--color-body)]">{b}</p>
                </Card>
              ))}
            </div>
          </div>
        </section>

        <section className="section bg-[var(--color-surface-dark)] text-white">
          <div className="container-edge">
            <span className="text-[12px] font-semibold uppercase tracking-[0.096em] text-[var(--color-on-dark-soft)]">
              Strategic positioning
            </span>
            <h2 className="font-display mt-3 max-w-2xl text-3xl text-white md:text-4xl">
              What Bright Future can become
            </h2>
            <ul className="mt-10 grid gap-3 sm:grid-cols-2">
              {positioning.map((p) => (
                <li key={p} className="reveal flex items-center gap-3 rounded-xl border border-white/10 bg-[var(--color-surface-dark-elevated)] p-5 text-[16px] text-white">
                  <span className="text-[var(--color-mint)]">◆</span>
                  {p}
                </li>
              ))}
            </ul>
          </div>
        </section>

        <section className="section border-t border-[var(--color-hairline)] bg-[var(--color-canvas-soft)]">
          <div className="container-edge text-center">
            <h2 className="font-display mx-auto max-w-2xl text-3xl md:text-5xl">
              Building tomorrow&apos;s digital leaders
            </h2>
            <div className="mt-8 flex justify-center gap-3">
              <ButtonLink href="/signup" variant="primary" className="h-11 px-7">
                Join Bright Future
              </ButtonLink>
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
