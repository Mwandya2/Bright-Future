"use client";

import { useActionState } from "react";
import Link from "next/link";
import { signup, type AuthState } from "@/app/actions/auth";
import { Button, Card, Input, Label } from "@/components/ui";

export default function SignupPage() {
  const [state, action, pending] = useActionState<AuthState, FormData>(signup, {});

  return (
    <Card className="w-full max-w-md p-8">
      <h1 className="font-display text-3xl">Create your account</h1>
      <p className="mt-2 text-[15px] text-[var(--color-body)]">
        Start learning, booking, and building — it&apos;s free.
      </p>

      {state.error && (
        <div className="mt-5 rounded-lg border border-[var(--color-error)]/30 bg-[var(--color-error)]/5 px-4 py-3 text-[14px] text-[var(--color-error)]">
          {state.error}
        </div>
      )}
      {state.message && (
        <div className="mt-5 rounded-lg border border-[var(--color-success)]/30 bg-[var(--color-success)]/5 px-4 py-3 text-[14px] text-[var(--color-success)]">
          {state.message}
        </div>
      )}

      <form action={action} className="mt-6 space-y-4">
        <div>
          <Label htmlFor="full_name">Full name</Label>
          <Input id="full_name" name="full_name" placeholder="Amina Juma" required />
        </div>
        <div>
          <Label htmlFor="email">Email</Label>
          <Input id="email" name="email" type="email" placeholder="you@email.com" required />
        </div>
        <div>
          <Label htmlFor="password">Password</Label>
          <Input id="password" name="password" type="password" placeholder="At least 6 characters" required minLength={6} />
        </div>
        <Button type="submit" disabled={pending} className="w-full h-11">
          {pending ? "Creating account…" : "Create account"}
        </Button>
      </form>

      <p className="mt-6 text-center text-[14px] text-[var(--color-body)]">
        Already have an account?{" "}
        <Link href="/login" className="font-medium text-[var(--color-ink)] underline">
          Sign in
        </Link>
      </p>
    </Card>
  );
}
