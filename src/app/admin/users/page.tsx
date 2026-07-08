import { createAdminClient } from "@/lib/supabase/admin";
import { Card } from "@/components/ui";
import { StatusSelect } from "@/components/status-select";
import { setUserRole } from "@/app/actions/admin";
import { ADMIN_EMAIL } from "@/lib/admin";
import type { Profile } from "@/lib/types";

export const metadata = { title: "Users" };

// Single-admin lock: "admin" is intentionally NOT selectable — only the one
// designated admin account (by email) can ever be admin.
const ROLES = [
  { value: "student", label: "Student" },
  { value: "instructor", label: "Instructor" },
];

export default async function AdminUsersPage() {
  const supabase = createAdminClient();
  const { data } = await supabase
    .from("profiles")
    .select("*")
    .order("created_at", { ascending: false });
  const users = (data ?? []) as Profile[];

  return (
    <div className="mx-auto max-w-6xl">
      <h1 className="font-display text-3xl md:text-4xl">Users</h1>
      <p className="mt-2 text-[15px] text-[var(--color-body)]">
        {users.length} member{users.length === 1 ? "" : "s"} on the platform.
      </p>

      <Card className="mt-8 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-[14px]">
            <thead className="border-b border-[var(--color-hairline)] bg-[var(--color-canvas-soft)] text-[12px] uppercase tracking-[0.06em] text-[var(--color-muted)]">
              <tr>
                <th className="px-5 py-3 font-semibold">Name</th>
                <th className="px-5 py-3 font-semibold">Email</th>
                <th className="px-5 py-3 font-semibold">Joined</th>
                <th className="px-5 py-3 font-semibold">Role</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[var(--color-hairline)]">
              {users.map((u) => (
                <tr key={u.id}>
                  <td className="px-5 py-3 font-medium text-[var(--color-ink)]">
                    {u.full_name ?? "—"}
                  </td>
                  <td className="px-5 py-3 text-[var(--color-body)]">{u.email ?? "—"}</td>
                  <td className="px-5 py-3 text-[var(--color-body)]">
                    {new Date(u.created_at).toLocaleDateString()}
                  </td>
                  <td className="px-5 py-3">
                    {u.email?.toLowerCase() === ADMIN_EMAIL ? (
                      <span className="inline-flex items-center rounded-full bg-[var(--color-ink)] px-2.5 py-1 text-[11px] font-semibold uppercase tracking-[0.06em] text-white">
                        Admin · locked
                      </span>
                    ) : (
                      <form action={setUserRole}>
                        <input type="hidden" name="id" value={u.id} />
                        <StatusSelect name="role" defaultValue={u.role} options={ROLES} />
                      </form>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
