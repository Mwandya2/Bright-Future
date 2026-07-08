"use client";

import { useActionState } from "react";
import { sendContactMessage, type ContactState } from "@/app/actions/contact";
import { Button, Input, Label, Textarea } from "@/components/ui";

export function ContactForm() {
  const [state, action, pending] = useActionState<ContactState, FormData>(
    sendContactMessage,
    {},
  );

  return (
    <form action={action} className="space-y-4">
      {state.error && (
        <p className="rounded-lg border border-[var(--color-error)]/30 bg-[var(--color-error)]/5 px-4 py-2.5 text-[14px] text-[var(--color-error)]">
          {state.error}
        </p>
      )}
      {state.success && (
        <p className="rounded-lg border border-[var(--color-success)]/30 bg-[var(--color-success)]/5 px-4 py-2.5 text-[14px] text-[var(--color-success)]">
          {state.success}
        </p>
      )}
      <div className="grid gap-4 sm:grid-cols-2">
        <div>
          <Label htmlFor="name">Name</Label>
          <Input id="name" name="name" placeholder="Your name" required />
        </div>
        <div>
          <Label htmlFor="email">Email</Label>
          <Input id="email" name="email" type="email" placeholder="you@email.com" required />
        </div>
      </div>
      <div>
        <Label htmlFor="subject">Subject</Label>
        <Input id="subject" name="subject" placeholder="How can we help?" />
      </div>
      <div>
        <Label htmlFor="message">Message</Label>
        <Textarea id="message" name="message" placeholder="Write your message…" required className="min-h-32" />
      </div>
      <Button type="submit" disabled={pending} className="h-11 w-full sm:w-auto sm:px-8">
        {pending ? "Sending…" : "Send message"}
      </Button>
    </form>
  );
}
