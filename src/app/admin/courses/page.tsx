import { createAdminClient } from "@/lib/supabase/admin";
import { Card, Badge } from "@/components/ui";
import { CourseForm } from "@/components/course-form";
import { togglePublish, deleteCourse } from "@/app/actions/admin";
import type { Course } from "@/lib/types";

export const metadata = { title: "Manage Courses" };

export default async function AdminCoursesPage() {
  const supabase = createAdminClient();
  const { data } = await supabase
    .from("courses")
    .select("*")
    .order("created_at", { ascending: false });
  const courses = (data ?? []) as Course[];

  return (
    <div className="mx-auto max-w-6xl">
      <h1 className="font-display text-3xl md:text-4xl">Manage courses</h1>
      <p className="mt-2 text-[15px] text-[var(--color-body)]">
        Create and publish courses for the ICT Training Academy.
      </p>

      <div className="mt-8 grid gap-6 lg:grid-cols-[1fr_1.3fr]">
        <Card className="h-fit p-6">
          <h2 className="text-[18px] font-medium text-[var(--color-ink)]">New course</h2>
          <div className="mt-4">
            <CourseForm />
          </div>
        </Card>

        <Card className="p-6">
          <h2 className="text-[18px] font-medium text-[var(--color-ink)]">
            All courses ({courses.length})
          </h2>
          {courses.length === 0 ? (
            <p className="mt-4 text-[14px] text-[var(--color-body)]">
              No courses yet — create your first on the left.
            </p>
          ) : (
            <ul className="mt-4 divide-y divide-[var(--color-hairline)]">
              {courses.map((c) => (
                <li key={c.id} className="flex items-center justify-between gap-3 py-3">
                  <div className="min-w-0">
                    <div className="flex items-center gap-2">
                      <span className="truncate text-[15px] font-medium text-[var(--color-ink)]">
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
                    <div className="text-[13px] capitalize text-[var(--color-muted)]">
                      {c.category} · {c.level} · {c.price === 0 ? "Free" : `TZS ${c.price.toLocaleString()}`}
                    </div>
                  </div>
                  <div className="flex shrink-0 items-center gap-3">
                    <form action={togglePublish}>
                      <input type="hidden" name="id" value={c.id} />
                      <input type="hidden" name="is_published" value={String(!c.is_published)} />
                      <button className="text-[13px] font-medium text-[var(--color-ink)] hover:underline">
                        {c.is_published ? "Unpublish" : "Publish"}
                      </button>
                    </form>
                    <form action={deleteCourse}>
                      <input type="hidden" name="id" value={c.id} />
                      <button className="text-[13px] font-medium text-[var(--color-error)] hover:underline">
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
