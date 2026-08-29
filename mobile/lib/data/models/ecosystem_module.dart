/// The Bright Future ecosystem modules, mirrored from
/// `frontend/src/lib/modules.ts` so the app and site stay in step.
class ModuleFeature {
  const ModuleFeature(this.title, this.body);
  final String title;
  final String body;
}

class EcosystemModule {
  const EcosystemModule({
    required this.slug,
    required this.title,
    required this.tagline,
    required this.label,
    required this.cover,
    required this.summary,
    required this.overview,
    required this.features,
    required this.isLive,
    this.ctaLabel,
    this.ctaRoute,
  });

  final String slug;
  final String title;
  final String tagline;
  final String label;
  final String cover;
  final String summary;
  final String overview;
  final List<ModuleFeature> features;
  final bool isLive;
  final String? ctaLabel;
  final String? ctaRoute;
}

const List<EcosystemModule> kEcosystemModules = <EcosystemModule>[
  EcosystemModule(
    slug: 'ict-training-academy',
    title: 'ICT Training Academy',
    tagline: 'Practical, certificate-backed digital skills training.',
    label: 'Academy',
    cover: 'sky',
    summary: 'Course marketplace, smart learning, certifications.',
    overview:
        'A complete learning academy offering structured, job-ready courses '
        'across web development, design, data, networking, and productivity - '
        'with certificates, instructor support, and a smart learning experience.',
    features: <ModuleFeature>[
      ModuleFeature('Course marketplace',
          'Browse and enrol in curated ICT courses across every level.'),
      ModuleFeature('Smart learning experience',
          'Structured lessons, progress tracking, and hands-on projects.'),
      ModuleFeature('Certifications',
          'Earn recognised certificates on completion of each course.'),
      ModuleFeature('Instructor management',
          'Vetted instructors deliver and support every programme.'),
    ],
    isLive: true,
    ctaLabel: 'Browse courses',
    ctaRoute: '/courses',
  ),
  EcosystemModule(
    slug: 'computer-lab',
    title: 'Computer Lab & Internet',
    tagline: 'Book workstations and managed internet access.',
    label: 'Lab',
    cover: 'mint',
    summary: 'Smart booking, session tracking, access control.',
    overview:
        'Reserve computer, gaming, or research workstations with real-time '
        'booking, automatic session tracking, and managed internet access - all '
        'from your account.',
    features: <ModuleFeature>[
      ModuleFeature('Smart lab booking',
          'Reserve a workstation by type, date, time, and duration.'),
      ModuleFeature('Session tracking',
          'Automatic tracking of usage and session length.'),
      ModuleFeature('Internet access management',
          'Managed, monitored connectivity for every session.'),
      ModuleFeature('Gaming & research stations',
          'Dedicated machines for gaming, study, and research.'),
    ],
    isLive: true,
    ctaLabel: 'Book a workstation',
    ctaRoute: '/bookings',
  ),
  EcosystemModule(
    slug: 'digital-printing',
    title: 'Digital Printing & Media',
    tagline: 'Print, design, and collect - the smart way.',
    label: 'Printing',
    cover: 'peach',
    summary: 'Print, posters, banners, cards, photos, delivery.',
    overview:
        'Submit documents, posters, banners, business cards, and photos for '
        'printing through a smart upload system, with pricing estimates and easy '
        'collection or delivery.',
    features: <ModuleFeature>[
      ModuleFeature('Document printing', 'Black & white or colour, any quantity.'),
      ModuleFeature('Posters & banners',
          'Large-format printing for events and campaigns.'),
      ModuleFeature('Business cards', 'Professional cards designed and printed.'),
      ModuleFeature('Photo printing', 'High-quality photo prints in multiple sizes.'),
      ModuleFeature('Smart upload & delivery',
          'Upload files from your phone and collect or have them delivered.'),
    ],
    isLive: true,
    ctaLabel: 'Request printing',
    ctaRoute: '/printing',
  ),
  EcosystemModule(
    slug: 'freelance-marketplace',
    title: 'Digital Freelance Marketplace',
    tagline: 'Creative and technical services on demand.',
    label: 'Freelance',
    cover: 'lavender',
    summary: 'Design, web, social, video, branding & IT.',
    overview:
        'A marketplace connecting you with vetted local talent for design, '
        'development, and digital services - delivered professionally, on time.',
    features: <ModuleFeature>[
      ModuleFeature('Logo & brand design',
          'Distinctive identities for businesses and creators.'),
      ModuleFeature('Website development', 'Modern, responsive websites and web apps.'),
      ModuleFeature('Social media management',
          'Content, scheduling, and growth support.'),
      ModuleFeature('Video editing', 'Professional editing for ads, reels, and events.'),
    ],
    isLive: false,
  ),
  EcosystemModule(
    slug: 'business-hub',
    title: 'Business & Entrepreneurship Hub',
    tagline: 'Tools to launch and grow a digital business.',
    label: 'Business',
    cover: 'rose',
    summary: 'Profiles, storefronts, marketing, accounting.',
    overview:
        'Everything an entrepreneur needs to establish an online presence and '
        'run day-to-day operations - from digital storefronts to marketing and '
        'simple accounting.',
    features: <ModuleFeature>[
      ModuleFeature('Business profiles',
          'Create a professional presence for your venture.'),
      ModuleFeature('Digital storefronts',
          'Showcase and sell products and services online.'),
      ModuleFeature('Marketing support', 'Promote your business across digital channels.'),
      ModuleFeature('Inventory & accounting',
          'Lightweight tools to track stock and finances.'),
    ],
    isLive: false,
  ),
  EcosystemModule(
    slug: 'career-center',
    title: 'Career & Job Center',
    tagline: 'Bridge from skills to employment.',
    label: 'Careers',
    cover: 'sky',
    summary: 'CV builder, internships, job board, mentorship.',
    overview:
        'Connect your new skills to real opportunities with a CV builder, '
        'curated internships and jobs, and access to experienced mentors.',
    features: <ModuleFeature>[
      ModuleFeature('CV builder', 'Create a polished, professional CV in minutes.'),
      ModuleFeature('Internship listings', 'Find hands-on internship opportunities.'),
      ModuleFeature('Job board', 'Discover roles matched to your skills.'),
      ModuleFeature('Career mentorship', 'Guidance from experienced professionals.'),
    ],
    isLive: false,
  ),
  EcosystemModule(
    slug: 'events-community',
    title: 'Events & Tech Community',
    tagline: 'Learn, connect, and build together.',
    label: 'Community',
    cover: 'mint',
    summary: 'Workshops, bootcamps, networking, challenges.',
    overview:
        'A vibrant community of learners, entrepreneurs, and mentors - with '
        'workshops, bootcamps, networking events, innovation challenges, and forums.',
    features: <ModuleFeature>[
      ModuleFeature('Workshops', 'Hands-on sessions on trending tech topics.'),
      ModuleFeature('Bootcamps', 'Intensive programmes to fast-track skills.'),
      ModuleFeature('Networking events', 'Meet peers, mentors, and employers.'),
      ModuleFeature('Community forums', 'Ask, share, and grow together.'),
    ],
    isLive: false,
  ),
];

EcosystemModule? findModule(String slug) {
  for (final EcosystemModule m in kEcosystemModules) {
    if (m.slug == slug) return m;
  }
  return null;
}
