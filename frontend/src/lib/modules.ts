export type ModuleDef = {
  slug: string;
  title: string;
  tagline: string;
  label: string; // short eyebrow / badge
  cover: string; // cover-* gradient class
  summary: string; // short grid description
  overview: string; // longer intro on the detail page
  features: { title: string; body: string }[];
  status: "live" | "coming-soon";
  ctaLabel?: string;
  ctaHref?: string;
};

/**
 * The Bright Future ecosystem modules. (E-Commerce Tech Store intentionally
 * excluded — not part of the covered scope.)
 */
export const MODULES: ModuleDef[] = [
  {
    slug: "ict-training-academy",
    title: "ICT Training Academy",
    tagline: "Practical, certificate-backed digital skills training.",
    label: "Academy",
    cover: "cover-sky",
    summary: "Course marketplace, smart learning, certifications.",
    overview:
      "A complete learning academy offering structured, job-ready courses across web development, design, data, networking, and productivity — with certificates, instructor support, and a smart, AI-assisted learning experience.",
    features: [
      { title: "Course marketplace", body: "Browse and enrol in curated ICT courses across every level." },
      { title: "Smart learning experience", body: "Structured lessons, progress tracking, and hands-on projects." },
      { title: "AI-powered features", body: "An AI learning assistant that helps explain concepts and guide practice." },
      { title: "Certifications", body: "Earn recognised certificates on completion of each course." },
      { title: "Instructor management", body: "Vetted instructors deliver and support every programme." },
    ],
    status: "live",
    ctaLabel: "Browse courses",
    ctaHref: "/courses",
  },
  {
    slug: "computer-lab",
    title: "Computer Lab & Internet",
    tagline: "Book workstations and managed internet access.",
    label: "Lab",
    cover: "cover-mint",
    summary: "Smart booking, session tracking, access control.",
    overview:
      "Reserve computer, gaming, or research workstations with real-time booking, automatic session tracking, and managed internet access — all from your account.",
    features: [
      { title: "Smart lab booking", body: "Reserve a workstation by type, date, time, and duration." },
      { title: "Session tracking", body: "Automatic tracking of usage and session length." },
      { title: "Internet access management", body: "Managed, monitored connectivity for every session." },
      { title: "Gaming & research stations", body: "Dedicated machines for gaming, study, and research." },
    ],
    status: "live",
    ctaLabel: "Book a workstation",
    ctaHref: "/dashboard/bookings",
  },
  {
    slug: "digital-printing",
    title: "Digital Printing & Media",
    tagline: "Print, design, and collect — the smart way.",
    label: "Printing",
    cover: "cover-peach",
    summary: "Print, posters, banners, cards, photos, delivery.",
    overview:
      "Submit documents, posters, banners, business cards, and photos for printing through a smart upload system, with pricing estimates and easy collection or delivery.",
    features: [
      { title: "Document printing", body: "Black & white or colour, any quantity." },
      { title: "Posters & banners", body: "Large-format printing for events and campaigns." },
      { title: "Business cards", body: "Professional cards designed and printed." },
      { title: "Photo printing", body: "High-quality photo prints in multiple sizes." },
      { title: "Smart upload & delivery", body: "Upload files online and collect or have them delivered." },
    ],
    status: "live",
    ctaLabel: "Request printing",
    ctaHref: "/dashboard/printing",
  },
  {
    slug: "freelance-marketplace",
    title: "Digital Freelance Marketplace",
    tagline: "Creative and technical services on demand.",
    label: "Freelance",
    cover: "cover-lavender",
    summary: "Design, web, social, video, branding & IT.",
    overview:
      "A marketplace connecting you with vetted local talent for design, development, and digital services — delivered professionally, on time.",
    features: [
      { title: "Logo & brand design", body: "Distinctive identities for businesses and creators." },
      { title: "Website development", body: "Modern, responsive websites and web apps." },
      { title: "Social media management", body: "Content, scheduling, and growth support." },
      { title: "Video editing", body: "Professional editing for ads, reels, and events." },
      { title: "Branding & IT support", body: "End-to-end brand and technical assistance." },
    ],
    status: "coming-soon",
  },
  {
    slug: "business-hub",
    title: "Business & Entrepreneurship Hub",
    tagline: "Tools to launch and grow a digital business.",
    label: "Business",
    cover: "cover-rose",
    summary: "Profiles, storefronts, marketing, accounting.",
    overview:
      "Everything an entrepreneur needs to establish an online presence and run day-to-day operations — from digital storefronts to marketing and simple accounting.",
    features: [
      { title: "Business profiles", body: "Create a professional presence for your venture." },
      { title: "Digital storefronts", body: "Showcase and sell products and services online." },
      { title: "Marketing support", body: "Promote your business across digital channels." },
      { title: "Inventory & accounting", body: "Lightweight tools to track stock and finances." },
    ],
    status: "coming-soon",
  },
  {
    slug: "career-center",
    title: "Career & Job Center",
    tagline: "Bridge from skills to employment.",
    label: "Careers",
    cover: "cover-sky",
    summary: "CV builder, internships, job board, mentorship.",
    overview:
      "Connect your new skills to real opportunities with a CV builder, curated internships and jobs, and access to experienced mentors.",
    features: [
      { title: "CV builder", body: "Create a polished, professional CV in minutes." },
      { title: "Internship listings", body: "Find hands-on internship opportunities." },
      { title: "Job board", body: "Discover roles matched to your skills." },
      { title: "Career mentorship", body: "Guidance from experienced professionals." },
    ],
    status: "coming-soon",
  },
  {
    slug: "events-community",
    title: "Events & Tech Community",
    tagline: "Learn, connect, and build together.",
    label: "Community",
    cover: "cover-mint",
    summary: "Workshops, bootcamps, networking, challenges.",
    overview:
      "A vibrant community of learners, entrepreneurs, and mentors — with workshops, bootcamps, networking events, innovation challenges, and forums.",
    features: [
      { title: "Workshops", body: "Hands-on sessions on trending tech topics." },
      { title: "Bootcamps", body: "Intensive programmes to fast-track skills." },
      { title: "Networking events", body: "Meet peers, mentors, and employers." },
      { title: "Innovation challenges", body: "Compete and build with real-world problems." },
      { title: "Community forums", body: "Ask, share, and grow together." },
    ],
    status: "coming-soon",
  },
  {
    slug: "smart-administration",
    title: "Smart Administration",
    tagline: "The intelligent engine behind the platform.",
    label: "Admin",
    cover: "cover-lavender",
    summary: "Users, payments, analytics, revenue, notifications.",
    overview:
      "The management backbone of Bright Future — giving administrators a clear, real-time view of users, payments, analytics, and revenue across every module.",
    features: [
      { title: "User management", body: "Oversee members, roles, and access." },
      { title: "Payment tracking", body: "Monitor transactions across services." },
      { title: "Analytics dashboard", body: "Real-time insight into platform activity." },
      { title: "Revenue reports", body: "Understand performance and growth." },
      { title: "Notification management", body: "Keep everyone informed automatically." },
    ],
    status: "coming-soon",
  },
];

export function getModule(slug: string) {
  return MODULES.find((m) => m.slug === slug);
}
