import Link from "next/link";
import { BrandLogo } from "@/components/brand-logo";

const cols = [
  {
    title: "Platform",
    links: [
      ["Courses", "/courses"],
      ["Lab Booking", "/dashboard/bookings"],
      ["Digital Printing", "/dashboard/printing"],
      ["Dashboard", "/dashboard"],
    ],
  },
  {
    title: "Ecosystem",
    links: [
      ["Freelance Services", "/#modules"],
      ["Business Hub", "/#modules"],
      ["Career Center", "/#modules"],
      ["Tech Store", "/#modules"],
    ],
  },
  {
    title: "Company",
    links: [
      ["About", "/about"],
      ["Pricing", "/#pricing"],
      ["Contact", "/contact"],
      ["Sign in", "/login"],
    ],
  },
];

export function SiteFooter() {
  return (
    <footer className="border-t border-[var(--color-hairline)] bg-[var(--color-canvas)]">
      <div className="container-edge grid gap-10 py-16 md:grid-cols-[1.4fr_repeat(3,1fr)]">
        <div>
          <BrandLogo href={null} size={34} />
          <p className="mt-4 max-w-xs text-[15px] text-[var(--color-body)]">
            A complete digital empowerment ecosystem for education,
            entrepreneurship, and innovation.
          </p>
          <p className="mt-4 text-[13px] text-[var(--color-muted-soft)]">
            Empowering Digital Futures
          </p>
        </div>
        {cols.map((c) => (
          <div key={c.title}>
            <h4 className="text-[12px] font-semibold uppercase tracking-[0.096em] text-[var(--color-muted)]">
              {c.title}
            </h4>
            <ul className="mt-4 space-y-3">
              {c.links.map(([label, href]) => (
                <li key={label}>
                  <Link
                    href={href}
                    className="text-[15px] text-[var(--color-body)] hover:text-[var(--color-ink)]"
                  >
                    {label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>
      <div className="border-t border-[var(--color-hairline)]">
        <div className="container-edge flex flex-col items-center justify-between gap-2 py-6 text-[13px] text-[var(--color-muted)] sm:flex-row">
          <span>© {new Date().getFullYear()} Bright Future Digital Hub. All rights reserved.</span>
          <span>brightfuture.best</span>
        </div>
      </div>
    </footer>
  );
}
