import { requireProfile } from "@/lib/auth";
import { apiClient } from "@/lib/api-client";
import { Card, ButtonLink, Badge } from "@/components/ui";
import type { Enrollment } from "@/lib/types";

export const metadata = { title: "My Courses" };

export default async function MyCoursesPage() {
  await requireProfile();

  const res = await apiClient.get<Enrollment[]>("/enrollments/my");
  const enrollments = res.data ?? [];

  return (
    <div className="mx-auto max-w-5xl">
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="font-display text-2xl sm:text-3xl md:text-4xl">My courses</h1>
          <p className="mt-2 text-[14px] sm:text-[15px] text-[var(--color-body)]">
            Track your enrolled ICT training.
          </p>
        </div>
        <ButtonLink href="/courses" variant="primary" className="self-start sm:self-auto">Browse catalog</ButtonLink>
      </div>

      {enrollments.length === 0 ? (
        <Card className="mt-8 p-8 sm:p-10 text-center">
          <h2 className="text-xl font-medium text-[var(--color-ink)]">
            You haven&apos;t enrolled yet
          </h2>
          <p className="mt-2 text-[14px] sm:text-[15px] text-[var(--color-body)]">
            Explore the catalog and start your first ICT course.
          </p>
          <div className="mt-6">
            <ButtonLink href="/courses" variant="outline">View courses</ButtonLink>
          </div>
        </Card>
      ) : (
        <div className="mt-8 grid gap-4 grid-cols-1 sm:grid-cols-2">
          {enrollments.map((e) => (
            <Card key={e.id} className="p-5 sm:p-6">
              <div className="flex items-center justify-between">
                <Badge>{e.status}</Badge>
                <span className="text-[13px] text-[var(--color-muted)]">{e.progress}%</span>
              </div>
              <h3 className="mt-3 text-[17px] font-medium text-[var(--color-ink)]">
                {e.course?.title ?? "Course"}
              </h3>
              <div className="mt-4 h-1.5 overflow-hidden rounded-full bg-[var(--color-surface-strong)]">
                <div className="h-full rounded-full bg-[var(--color-ink)]" style={{ width: `${e.progress}%` }} />
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
