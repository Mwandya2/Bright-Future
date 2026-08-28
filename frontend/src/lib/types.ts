export type Role = "student" | "instructor" | "admin" | "STUDENT" | "INSTRUCTOR" | "ADMIN";

export type Profile = {
  id: string;
  full_name: string | null;
  fullName?: string | null;
  email: string | null;
  phone: string | null;
  role: "student" | "instructor" | "admin";
  avatar_url: string | null;
  avatarUrl?: string | null;
  created_at: string;
  createdAt?: string;
};

export type Course = {
  id: string;
  title: string;
  slug: string;
  summary: string | null;
  description: string | null;
  category: string | null;
  level: "beginner" | "intermediate" | "advanced" | "BEGINNER" | "INTERMEDIATE" | "ADVANCED";
  price: number;
  duration_weeks: number | null;
  durationWeeks?: number | null;
  instructor_name: string | null;
  instructorName?: string | null;
  cover_gradient: string | null;
  coverGradient?: string | null;
  is_published: boolean;
  isPublished?: boolean;
  created_at: string;
  createdAt?: string;
};

export type Enrollment = {
  id: string;
  user_id: string;
  userId?: string;
  course_id: string;
  courseId?: string;
  status: "active" | "completed" | "cancelled" | "ACTIVE" | "COMPLETED" | "CANCELLED";
  progress: number;
  created_at: string;
  createdAt?: string;
  course?: Course;
  user?: Profile;
};

export type LabBooking = {
  id: string;
  user_id: string;
  userId?: string;
  workstation_type: "computer" | "gaming" | "research" | "printing_station" | "COMPUTER" | "GAMING" | "RESEARCH" | "PRINTING_STATION";
  workstationType?: "computer" | "gaming" | "research" | "printing_station" | "COMPUTER" | "GAMING" | "RESEARCH" | "PRINTING_STATION";
  booking_date: string;
  bookingDate?: string;
  start_time: string;
  startTime?: string;
  duration_hours: number;
  durationHours?: number;
  status: "pending" | "confirmed" | "completed" | "cancelled" | "PENDING" | "CONFIRMED" | "COMPLETED" | "CANCELLED";
  notes: string | null;
  created_at: string;
  createdAt?: string;
  profile?: Pick<Profile, "full_name" | "email">;
  user?: Profile;
};

export type PrintOrder = {
  id: string;
  user_id: string;
  userId?: string;
  service_type:
    | "document"
    | "poster"
    | "banner"
    | "business_card"
    | "photo"
    | "DOCUMENT"
    | "POSTER"
    | "BANNER"
    | "BUSINESS_CARD"
    | "PHOTO";
  serviceType?:
    | "document"
    | "poster"
    | "banner"
    | "business_card"
    | "photo"
    | "DOCUMENT"
    | "POSTER"
    | "BANNER"
    | "BUSINESS_CARD"
    | "PHOTO";
  description: string | null;
  copies: number;
  color: boolean;
  status:
    | "submitted"
    | "in_progress"
    | "ready"
    | "collected"
    | "cancelled"
    | "SUBMITTED"
    | "IN_PROGRESS"
    | "READY"
    | "COLLECTED"
    | "CANCELLED";
  estimated_price: number | null;
  estimatedPrice?: number | null;
  created_at: string;
  createdAt?: string;
  profile?: Pick<Profile, "full_name" | "email">;
  user?: Profile;
};

export type ContactMessage = {
  id: string;
  name: string;
  email: string;
  subject: string | null;
  message: string;
  created_at: string;
  createdAt?: string;
};

export type AdminStats = {
  totalUsers: number;
  totalCourses: number;
  publishedCourses: number;
  totalBookings: number;
  pendingBookings: number;
  totalPrintOrders: number;
  activePrintOrders: number;
  totalContactMessages: number;
};

export type ApiResponse<T> = {
  success: boolean;
  message?: string;
  data?: T;
  timestamp?: string;
};

export const CATEGORY_LABELS: Record<string, string> = {
  ict: "ICT Fundamentals",
  web: "Web Development",
  design: "Graphic Design",
  data: "Data & AI",
  office: "Office & Productivity",
  networking: "Networking",
};

export const GRADIENTS = [
  "mint",
  "peach",
  "lavender",
  "sky",
  "rose",
] as const;
