import { SiteNav } from "@/components/site-nav";
import { SiteFooter } from "@/components/site-footer";
import { GsapReveal } from "@/components/gsap-reveal";
import { ContactForm } from "@/components/contact-form";
import { Card, SectionLabel } from "@/components/ui";

export const metadata = { title: "Contact" };

const channels = [
  ["Email", "hello@brightfuture.best"],
  ["Support", "support@brightfuture.best"],
  ["Hours", "Mon–Sat · 8:00 – 20:00"],
];

export default function ContactPage() {
  return (
    <div className="flex min-h-screen flex-col">
      <GsapReveal />
      <SiteNav />
      <main className="flex-1">
        <section className="relative overflow-hidden border-b border-[var(--color-hairline)]">
          <div className="orb orb-sky" style={{ width: 340, height: 340, top: -120, left: -40 }} />
          <div className="container-edge relative z-10 py-24">
            <SectionLabel>Contact</SectionLabel>
            <h1 data-hero className="font-display mt-3 max-w-3xl text-4xl md:text-6xl">
              Let&apos;s talk
            </h1>
            <p data-hero className="mt-6 max-w-2xl text-lg text-[var(--color-body)]">
              Questions about courses, bookings, printing, or partnerships? Send
              us a message and the Bright Future team will get back to you.
            </p>
          </div>
        </section>

        <section className="section">
          <div className="container-edge grid gap-8 lg:grid-cols-[1.4fr_1fr]">
            <Card className="reveal p-7">
              <h2 className="text-[20px] font-medium text-[var(--color-ink)]">Send a message</h2>
              <div className="mt-5">
                <ContactForm />
              </div>
            </Card>

            <div className="reveal space-y-4">
              {channels.map(([label, value]) => (
                <Card key={label} className="p-6">
                  <div className="text-[12px] font-semibold uppercase tracking-[0.08em] text-[var(--color-muted)]">
                    {label}
                  </div>
                  <div className="mt-1 text-[16px] font-medium text-[var(--color-ink)]">
                    {value}
                  </div>
                </Card>
              ))}
            </div>
          </div>
        </section>
      </main>
      <SiteFooter />
    </div>
  );
}
