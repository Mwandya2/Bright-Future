import Link from "next/link";
import { SiteNav } from "@/components/site-nav";
import { SiteFooter } from "@/components/site-footer";
import { Badge, Card, Button, ButtonLink, SectionLabel } from "@/components/ui";
import { createClient } from "@/lib/supabase/server";
import { enrollSelf } from "@/app/actions/enroll";
import { isTheAdmin } from "@/lib/admin";
import { CATEGORY_LABELS, type Course } from "@/lib/types";

export const metadata = { title: "Courses" };

const COVERS = ["cover-mint", "cover-sky", "cover-peach", "cover-lavender", "cover-rose"];

function price(n: number) {
  return n === 0 ? "Free" : `TZS ${n.toLocaleString()}`;
}

export default async function CoursesPage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  let isAdmin = false;
  if (user) {
    const { data: prof } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();
    isAdmin = isTheAdmin(user.email, prof?.role);
  }

  const { data } = await supabase
    .from("courses")
    .select("*")
    .eq("is_published", true)
    .order("created_at", { ascending: false });

  const courses = (data ?? []) as Course[];

  return (
    <div className="flex min-h-screen flex-col">
      <SiteNav />
      <main className="flex-1">
        <section className="relative overflow-hidden border-b border-[var(--color-hairline)]">
          <div className="orb orb-mint" style={{ width: 360, height: 360, top: -120, right: -40 }} />
          <div className="container-edge relative z-10 py-20">
            <SectionLabel>ICT Training Academy</SectionLabel>
            <h1 className="font-display mt-3 max-w-3xl text-4xl md:text-5xl">
              Courses to build real digital skills
            </h1>
            <p className="mt-4 max-w-2xl text-[var(--color-body)]">
              Practical, certificate-backed training across web development,
              design, data, networking, and productivity.
            </p>
            {isAdmin ? (
              <p className="mt-4 text-[14px] text-[var(--color-muted)]">
                You&apos;re signed in as an administrator — manage the catalogue
                in the{" "}
                <Link href="/admin/courses" className="font-medium text-[var(--color-primary)] underline">
                  admin dashboard
                </Link>
                .
              </p>
            ) : (
              user && (
                <p className="mt-4 text-[14px] text-[var(--color-muted)]">
                  Signed in — enrolling adds the course to your account.
                  Enrolling someone else?{" "}
                  <Link href="/signup" className="font-medium text-[var(--color-primary)] underline">
                    Create a separate account
                  </Link>
                  .
                </p>
              )
            )}
          </div>
        </section>

        <section className="section">
          <div className="container-edge">
            {courses.length === 0 ? (
              <Card className="p-10 text-center">
                <h2 className="text-xl font-medium text-[var(--color-ink)]">
                  Courses are coming soon
                </h2>
                <p className="mt-2 text-[15px] text-[var(--color-body)]">
                  Run the seed SQL in Supabase to publish the starter catalog,
                  or check back shortly.
                </p>
                <div className="mt-6">
                  <ButtonLink href="/signup" variant="primary">
                    Create a free account
                  </ButtonLink>
                </div>
              </Card>
            ) : (
              <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
                {courses.map((c, i) => (
                  <Card key={c.id} className="group overflow-hidden">
                    <div className={`h-28 ${c.cover_gradient ? `cover-${c.cover_gradient}` : COVERS[i % COVERS.length]}`} />
                    <div className="p-6">
                      <div className="flex items-center gap-2">
                        <Badge>{CATEGORY_LABELS[c.category ?? ""] ?? c.category ?? "Course"}</Badge>
                        <span className="text-[12px] capitalize text-[var(--color-muted)]">
                          {c.level}
                        </span>
                      </div>
                      <h3 className="mt-3 text-[18px] font-medium text-[var(--color-ink)]">
                        {c.title}
                      </h3>
                      <p className="mt-1.5 line-clamp-2 text-[14px] text-[var(--color-body)]">
                        {c.summary}
                      </p>
                      <div className="mt-5 flex items-center justify-between">
                        <span className="font-display text-xl">{price(c.price)}</span>
                        <span className="text-[13px] text-[var(--color-muted)]">
                          {c.duration_weeks ? `${c.duration_weeks} weeks` : ""}
                        </span>
                      </div>
                      {isAdmin ? (
                        <ButtonLink
                          href="/admin/courses"
                          variant="outline"
                          className="mt-5 w-full"
                        >
                          Manage in admin
                        </ButtonLink>
                      ) : user ? (
                        <form action={enrollSelf} className="mt-5">
                          <input type="hidden" name="course_id" value={c.id} />
                          <Button variant="outline" className="w-full">
                            Enroll now
                          </Button>
                        </form>
                      ) : (
                        <ButtonLink
                          href="/login?redirect=/courses"
                          variant="outline"
                          className="mt-5 w-full"
                        >
                          Enroll now
                        </ButtonLink>
                      )}
                    </div>
                  </Card>
                ))}
              </div>
            )}
          </div>
        </section>
      </main>
      <SiteFooter />
    </div>
  );
}
