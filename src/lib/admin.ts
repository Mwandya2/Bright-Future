/**
 * Single-admin lock. The admin dashboard is restricted to exactly ONE account,
 * identified by this email. Admin access requires BOTH role='admin' AND a
 * matching email — so no other user can ever reach /admin, even if their role
 * were changed in the database.
 *
 * Falls back to the provisioned admin email if the env var is unset, to avoid
 * accidental lockout.
 */
export const ADMIN_EMAIL = (
  process.env.ADMIN_EMAIL || "admin@brightfuture.best.com"
).toLowerCase();

export function isTheAdmin(
  email: string | null | undefined,
  role: string | null | undefined,
): boolean {
  return role === "admin" && !!email && email.toLowerCase() === ADMIN_EMAIL;
}
