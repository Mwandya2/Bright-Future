"use client";

import { useActionState } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { Suspense } from "react";
import { login, type AuthState } from "@/app/actions/auth";
import { Button, Card, Input, Label } from "@/components/ui";

function LoginForm() {
  const [state, action, pending] = useActionState<AuthState, FormData>(login, {});
  const params = useSearchParams();
  const redirectTo = params.get("redirect") ?? "/dashboard";
  const confirmError = params.get("error");

  return (
    <Card className="w-full max-w-md p-8">
      <h1 className="font-display text-3xl">Welcome back</h1>
      <p className="mt-2 text-[15px] text-[var(--color-body)]">
        Sign in to your Bright Future account.
      </p>

      {(state.error || confirmError) && (
        <div className="mt-5 rounded-lg border border-[var(--color-error)]/30 bg-[var(--color-error)]/5 px-4 py-3 text-[14px] text-[var(--color-error)]">
          {state.error ??
            "Email confirmation failed or link expired. Please sign in or request a new link."}
        </div>
      )}

      <form action={action} className="mt-6 space-y-4">
        <input type="hidden" name="redirect" value={redirectTo} />
        <div>
          <Label htmlFor="email">Email</Label>
          <Input id="email" name="email" type="email" placeholder="you@email.com" required />
        </div>
        <div>
          <Label htmlFor="password">Password</Label>
          <Input id="password" name="password" type="password" placeholder="Your password" required />
        </div>
        <Button type="submit" disabled={pending} className="w-full h-11">
          {pending ? "Signing in…" : "Sign in"}
        </Button>
      </form>

      <p className="mt-6 text-center text-[14px] text-[var(--color-body)]">
        New to Bright Future?{" "}
        <Link href="/signup" className="font-medium text-[var(--color-ink)] underline">
          Create an account
        </Link>
      </p>
    </Card>
  );
}

export default function LoginPage() {
  return (
    <Suspense fallback={<Card className="w-full max-w-md p-8">Loading…</Card>}>
      <LoginForm />
    </Suspense>
  );
}
