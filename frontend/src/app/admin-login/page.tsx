"use client";

import { useActionState } from "react";
import Link from "next/link";
import { adminLogin, type AuthState } from "@/app/actions/auth";
import { BrandLogo } from "@/components/brand-logo";

export default function AdminLoginPage() {
  const [state, action, pending] = useActionState<AuthState, FormData>(
    adminLogin,
    {},
  );

  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden bg-[var(--color-surface-dark)] px-5">
      <div className="orb orb-lavender" style={{ width: 360, height: 360, top: -120, left: -60, opacity: 0.25 }} />
      <div className="orb orb-sky" style={{ width: 320, height: 320, bottom: -120, right: -60, opacity: 0.25 }} />

      <div className="relative z-10 w-full max-w-sm">
        <div className="mb-8">
          <BrandLogo href="/" size={36} wordmarkSize="text-[20px]" textClass="text-white" />
        </div>

        <div className="rounded-2xl border border-white/10 bg-[var(--color-surface-dark-elevated)] p-8">
          <span className="text-[12px] font-semibold uppercase tracking-[0.096em] text-[var(--color-on-dark-soft)]">
            Restricted
          </span>
          <h1 className="font-display mt-2 text-3xl text-white">Admin access</h1>
          <p className="mt-2 text-[14px] text-[var(--color-on-dark-soft)]">
            Administrator sign-in only. Regular members use the main site login.
          </p>

          {state.error && (
            <div className="mt-5 rounded-lg border border-[var(--color-error)]/40 bg-[var(--color-error)]/10 px-4 py-3 text-[14px] text-[#fca5a5]">
              {state.error}
            </div>
          )}

          <form action={action} className="mt-6 space-y-4">
            <div>
              <label htmlFor="email" className="mb-1.5 block text-[13px] font-medium text-white">
                Email
              </label>
              <input
                id="email"
                name="email"
                type="email"
                required
                placeholder="admin@brightfuture.best"
                className="h-11 w-full rounded-lg border border-white/15 bg-black/20 px-4 text-[15px] text-white placeholder:text-white/30 outline-none focus:border-white focus:ring-1 focus:ring-white"
              />
            </div>
            <div>
              <label htmlFor="password" className="mb-1.5 block text-[13px] font-medium text-white">
                Password
              </label>
              <input
                id="password"
                name="password"
                type="password"
                required
                placeholder="••••••••"
                className="h-11 w-full rounded-lg border border-white/15 bg-black/20 px-4 text-[15px] text-white placeholder:text-white/30 outline-none focus:border-white focus:ring-1 focus:ring-white"
              />
            </div>
            <button
              type="submit"
              disabled={pending}
              className="h-11 w-full rounded-full bg-white text-[15px] font-medium text-[var(--color-ink)] transition hover:bg-[var(--color-canvas)] disabled:opacity-50"
            >
              {pending ? "Signing in…" : "Enter admin dashboard"}
            </button>
          </form>
        </div>

        <p className="mt-6 text-center text-[13px] text-[var(--color-on-dark-soft)]">
          Not an admin?{" "}
          <Link href="/login" className="text-white underline">
            Member sign in
          </Link>
        </p>
      </div>
    </div>
  );
}
