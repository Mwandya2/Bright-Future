import { apiClient } from "@/lib/api-client";
import { requireProfile } from "@/lib/auth";
import { Card, Badge } from "@/components/ui";
import { CourseForm } from "@/components/course-form";
import { togglePublish, deleteCourse } from "@/app/actions/admin";
import type { Course } from "@/lib/types";

export const metadata = { title: "Manage Courses" };

export default async function AdminCoursesPage() {
  await requireProfile({ admin: true });

  const res = await apiClient.get<Course[]>("/courses/all");
  const rawCourses = (res.data ?? []) as Array<Record<string, unknown>>;
  const courses: Course[] = rawCourses.map((c) => ({
    id: String(c.id),
    title: String(c.title ?? ""),
    slug: String(c.slug ?? ""),
    summary: (c.summary as string) ?? null,
    description: (c.description as string) ?? null,
    category: (c.category as string) ?? "ict",
    level: ((c.level as string)?.toLowerCase() ?? "beginner") as Course["level"],
    price: Number(c.price ?? 0),
    duration_weeks: Number(c.durationWeeks ?? c.duration_weeks ?? 4),
    instructor_name: (c.instructorName ?? c.instructor_name) as string ?? null,
    cover_gradient: (c.coverGradient ?? c.cover_gradient) as string ?? "mint",
    is_published: Boolean(c.isPublished ?? c.is_published ?? false),
    created_at: String(c.createdAt ?? c.created_at ?? new Date().toISOString()),
  }));

  return (
    <div className="mx-auto max-w-6xl">
      <h1 className="font-display text-2xl sm:text-3xl md:text-4xl">Manage courses</h1>
      <p className="mt-2 text-[14px] sm:text-[15px] text-[var(--color-body)]">
        Create and publish courses for the ICT Training Academy.
      </p>

      <div className="mt-6 sm:mt-8 grid gap-6 grid-cols-1 lg:grid-cols-[1fr_1.3fr]">
        <Card className="h-fit p-5 sm:p-6">
          <h2 className="text-[17px] sm:text-[18px] font-medium text-[var(--color-ink)]">New course</h2>
          <div className="mt-4">
            <CourseForm />
          </div>
        </Card>

        <Card className="p-5 sm:p-6">
          <h2 className="text-[17px] sm:text-[18px] font-medium text-[var(--color-ink)]">
            All courses ({courses.length})
          </h2>
          {courses.length === 0 ? (
            <p className="mt-4 text-[14px] text-[var(--color-body)]">
              No courses yet — create your first on the left.
            </p>
          ) : (
            <ul className="mt-4 divide-y divide-[var(--color-hairline)]">
              {courses.map((c) => (
                <li key={c.id} className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 py-3">
                  <div className="min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="text-[14px] sm:text-[15px] font-medium text-[var(--color-ink)]">
                        {c.title}
                      </span>
                      {c.is_published ? (
                        <Badge>Live</Badge>
                      ) : (
                        <span className="text-[11px] font-semibold uppercase text-[var(--color-muted-soft)]">
                          Draft
                        </span>
                      )}
                    </div>
                    <div className="text-[12px] sm:text-[13px] capitalize text-[var(--color-muted)]">
                      {c.category} · {c.level} · {c.price === 0 ? "Free" : `TZS ${c.price.toLocaleString()}`}
                    </div>
                  </div>
                  <div className="flex shrink-0 items-center gap-3 self-end sm:self-auto">
                    <form action={togglePublish}>
                      <input type="hidden" name="id" value={c.id} />
                      <input type="hidden" name="is_published" value={String(!c.is_published)} />
                      <button className="text-[12px] sm:text-[13px] font-medium text-[var(--color-ink)] hover:underline min-h-[32px] px-2 py-1">
                        {c.is_published ? "Unpublish" : "Publish"}
                      </button>
                    </form>
                    <form action={deleteCourse}>
                      <input type="hidden" name="id" value={c.id} />
                      <button className="text-[12px] sm:text-[13px] font-medium text-[var(--color-error)] hover:underline min-h-[32px] px-2 py-1">
                        Delete
                      </button>
                    </form>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </Card>
      </div>
    </div>
  );
}
