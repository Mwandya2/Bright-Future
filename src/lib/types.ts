export type Role = "student" | "instructor" | "admin";

export type Profile = {
  id: string;
  full_name: string | null;
  email: string | null;
  phone: string | null;
  role: Role;
  avatar_url: string | null;
  created_at: string;
};

export type Course = {
  id: string;
  title: string;
  slug: string;
  summary: string | null;
  description: string | null;
  category: string | null;
  level: "beginner" | "intermediate" | "advanced";
  price: number;
  duration_weeks: number | null;
  instructor_name: string | null;
  cover_gradient: string | null;
  is_published: boolean;
  created_at: string;
};

export type Enrollment = {
  id: string;
  user_id: string;
  course_id: string;
  status: "active" | "completed" | "cancelled";
  progress: number;
  created_at: string;
  course?: Course;
};

export type LabBooking = {
  id: string;
  user_id: string;
  workstation_type: "computer" | "gaming" | "research" | "printing_station";
  booking_date: string;
  start_time: string;
  duration_hours: number;
  status: "pending" | "confirmed" | "completed" | "cancelled";
  notes: string | null;
  created_at: string;
  profile?: Pick<Profile, "full_name" | "email">;
};

export type PrintOrder = {
  id: string;
  user_id: string;
  service_type:
    | "document"
    | "poster"
    | "banner"
    | "business_card"
    | "photo";
  description: string | null;
  copies: number;
  color: boolean;
  status: "submitted" | "in_progress" | "ready" | "collected" | "cancelled";
  estimated_price: number | null;
  created_at: string;
  profile?: Pick<Profile, "full_name" | "email">;
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
