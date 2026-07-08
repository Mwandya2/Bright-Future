import Link from "next/link";
import { SiteNav } from "@/components/site-nav";
import { SiteFooter } from "@/components/site-footer";
import { ButtonLink, Card, Badge, SectionLabel } from "@/components/ui";
import { GsapReveal } from "@/components/gsap-reveal";

const services = [
  {
    tag: "Academy",
    title: "ICT Training Academy",
    body: "Structured courses in web development, design, data, networking, and office productivity — with certificates and instructor support.",
    href: "/courses",
    cover: "cover-mint",
  },
  {
    tag: "Lab",
    title: "Computer Lab & Internet",
    body: "Book computer, gaming, or research workstations. Session tracking and managed internet access built in.",
    href: "/dashboard/bookings",
    cover: "cover-sky",
  },
  {
    tag: "Printing",
    title: "Digital Printing & Media",
    body: "Documents, posters, banners, business cards, and photo printing with a smart upload and collection system.",
    href: "/dashboard/printing",
    cover: "cover-peach",
  },
  {
    tag: "Freelance",
    title: "Digital Services Marketplace",
    body: "Logo design, websites, social media, video editing, and IT support delivered by vetted local talent.",
    href: "/#modules",
    cover: "cover-lavender",
  },
];

const modules = [
  ["ICT Training Academy", "Course marketplace, smart learning, certifications"],
  ["Computer Lab Management", "Smart booking, session tracking, access control"],
  ["Digital Printing", "Print, posters, banners, cards, photos, delivery"],
  ["Freelance Marketplace", "Design, web, social, video, branding & IT"],
  ["Business & Entrepreneurship", "Profiles, storefronts, marketing, accounting"],
  ["Career & Job Center", "CV builder, internships, job board, mentorship"],
  ["Events & Tech Community", "Workshops, bootcamps, networking, challenges"],
  ["E-Commerce Tech Store", "Laptops, accessories, devices, books, licenses"],
  ["Smart Administration", "Users, payments, analytics, revenue, notifications"],
];

const smartFeatures = [
  "AI Learning Assistant",
  "Automated Support Chatbot",
  "QR Attendance System",
  "Digital Verification",
  "Gamification & Rewards",
  "Offline Learning Support",
];

const pricing = [
  {
    name: "Starter",
    price: "Free",
    note: "For students exploring digital skills",
    features: ["Browse all courses", "1 lab booking / week", "Community forums", "Basic printing rates"],
    featured: false,
  },
  {
    name: "Pro Learner",
    price: "TZS 15,000",
    note: "per month · most popular",
    features: ["All courses + certificates", "Unlimited lab bookings", "20% off printing", "Priority support", "AI learning assistant"],
    featured: true,
  },
  {
    name: "Business",
    price: "TZS 60,000",
    note: "per month · for SMEs & teams",
    features: ["Everything in Pro", "Team seats & storefront", "Marketing & accounting tools", "Freelance marketplace access", "Dedicated account manager"],
    featured: false,
  },
];

export default function Home() {
  return (
    <div className="flex min-h-screen flex-col">
      <GsapReveal />
      <SiteNav />
      <main className="flex-1">
        {/* Hero */}
        <section className="relative overflow-hidden">
          <div className="mesh-hero" />
          <div className="container-edge relative z-10 flex flex-col items-center py-28 text-center md:py-36">
            <div data-hero><Badge>ICT · Digital Services · Innovation</Badge></div>
            <h1 data-hero className="font-display mt-6 max-w-4xl text-5xl leading-[1.05] tracking-tight md:text-7xl">
              Empowering digital futures for the next generation
            </h1>
            <p data-hero className="mt-6 max-w-2xl text-lg text-[var(--color-body)] md:text-xl">
              Bright Future is a complete digital empowerment ecosystem — ICT
              education, computer-lab access, digital printing, freelance
              services, and business support in one modern platform.
            </p>
            <div data-hero className="mt-9 flex flex-wrap items-center justify-center gap-3">
              <ButtonLink href="/signup" variant="primary" className="h-11 px-6">
                Get started free
              </ButtonLink>
              <ButtonLink href="/courses" variant="outline" className="h-11 px-6">
                Explore courses
              </ButtonLink>
            </div>
            <div data-hero className="mt-14 grid w-full max-w-2xl grid-cols-3 gap-6">
              {[
                ["9", "Integrated modules"],
                ["50+", "ICT courses"],
                ["24/7", "Lab & support"],
              ].map(([n, l]) => (
                <div key={l}>
                  <div className="font-display text-3xl md:text-4xl">{n}</div>
                  <div className="mt-1 text-[13px] text-[var(--color-muted)]">{l}</div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Services */}
        <section id="services" className="section bg-[var(--color-canvas-soft)] border-y border-[var(--color-hairline)]">
          <div className="container-edge">
            <SectionLabel>Core services</SectionLabel>
            <h2 className="font-display mt-3 max-w-2xl text-3xl md:text-4xl">
              Everything you need to learn, create, and grow
            </h2>
            <div className="mt-12 grid gap-6 md:grid-cols-2">
              {services.map((s) => (
                <Link key={s.title} href={s.href} className="reveal">
                  <Card className="group h-full overflow-hidden transition hover:shadow-[0_4px_20px_rgba(0,0,0,0.05)]">
                    <div className={`h-32 ${s.cover}`} />
                    <div className="p-7">
                      <Badge>{s.tag}</Badge>
                      <h3 className="mt-4 text-xl font-medium text-[var(--color-ink)]">
                        {s.title}
                      </h3>
                      <p className="mt-2 text-[15px] text-[var(--color-body)]">
                        {s.body}
                      </p>
                      <span className="mt-4 inline-block text-[15px] font-medium text-[var(--color-ink)] group-hover:underline">
                        Learn more →
                      </span>
                    </div>
                  </Card>
                </Link>
              ))}
            </div>
          </div>
        </section>

        {/* Modules ecosystem */}
        <section id="modules" className="section">
          <div className="container-edge">
            <SectionLabel>The full ecosystem</SectionLabel>
            <h2 className="font-display mt-3 max-w-2xl text-3xl md:text-4xl">
              Nine modules. One digital platform.
            </h2>
            <p className="mt-4 max-w-2xl text-[var(--color-body)]">
              Bright Future scales from a learning academy into a complete
              digital transformation hub for education, entrepreneurship, and
              innovation.
            </p>
            <div className="mt-12 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {modules.map(([title, body], i) => (
                <Card key={title} className="reveal p-6">
                  <div className="text-[13px] font-semibold text-[var(--color-muted-soft)]">
                    {String(i + 1).padStart(2, "0")}
                  </div>
                  <h3 className="mt-2 text-[17px] font-medium text-[var(--color-ink)]">
                    {title}
                  </h3>
                  <p className="mt-1.5 text-[14px] text-[var(--color-body)]">{body}</p>
                </Card>
              ))}
            </div>
          </div>
        </section>

        {/* Smart features band */}
        <section className="section bg-[var(--color-surface-dark)] text-white">
          <div className="container-edge">
            <span className="text-[12px] font-semibold uppercase tracking-[0.096em] text-[var(--color-on-dark-soft)]">
              Smart features & innovation
            </span>
            <h2 className="font-display mt-3 max-w-2xl text-3xl text-white md:text-4xl">
              Intelligent technology, built in
            </h2>
            <div className="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
              {smartFeatures.map((f) => (
                <div
                  key={f}
                  className="reveal rounded-xl border border-white/10 bg-[var(--color-surface-dark-elevated)] p-5"
                >
                  <span className="text-[16px] font-medium text-white">{f}</span>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Pricing */}
        <section id="pricing" className="section">
          <div className="container-edge">
            <div className="text-center">
              <SectionLabel>Pricing</SectionLabel>
              <h2 className="font-display mt-3 text-3xl md:text-4xl">
                Simple plans for every stage
              </h2>
            </div>
            <div className="mt-12 grid gap-6 lg:grid-cols-3">
              {pricing.map((p) => (
                <Card
                  key={p.name}
                  className={p.featured ? "reveal border-0 p-8 text-white" : "reveal p-8"}
                  style={p.featured ? { backgroundColor: "var(--color-surface-dark)" } : undefined}
                >
                  <h3 className={p.featured ? "text-lg font-medium text-white" : "text-lg font-medium text-[var(--color-ink)]"}>
                    {p.name}
                  </h3>
                  <div className="font-display mt-4 text-4xl" style={p.featured ? { color: "#fff" } : undefined}>
                    {p.price}
                  </div>
                  <p className={p.featured ? "mt-1 text-[14px] text-[var(--color-on-dark-soft)]" : "mt-1 text-[14px] text-[var(--color-muted)]"}>
                    {p.note}
                  </p>
                  <ul className="mt-6 space-y-3">
                    {p.features.map((f) => (
                      <li key={f} className={p.featured ? "flex gap-2 text-[15px] text-white/90" : "flex gap-2 text-[15px] text-[var(--color-body)]"}>
                        <span className={p.featured ? "text-[var(--color-mint)]" : "text-[var(--color-success)]"}>✓</span>
                        {f}
                      </li>
                    ))}
                  </ul>
                  <ButtonLink
                    href="/signup"
                    variant={p.featured ? "dark" : "outline"}
                    className="mt-8 w-full"
                  >
                    Choose {p.name}
                  </ButtonLink>
                </Card>
              ))}
            </div>
          </div>
        </section>

        {/* CTA band */}
        <section className="section border-t border-[var(--color-hairline)] bg-[var(--color-canvas-soft)]">
          <div className="container-edge text-center">
            <h2 className="font-display mx-auto max-w-2xl text-3xl md:text-5xl">
              Learn. Connect. Grow.
            </h2>
            <p className="mx-auto mt-4 max-w-xl text-[var(--color-body)]">
              Join Bright Future and start building your digital future today.
            </p>
            <div className="mt-8">
              <ButtonLink href="/signup" variant="primary" className="h-11 px-7">
                Create your free account
              </ButtonLink>
            </div>
          </div>
        </section>
      </main>
      <SiteFooter />
    </div>
  );
}
