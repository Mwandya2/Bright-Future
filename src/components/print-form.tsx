"use client";

import { useActionState } from "react";
import { createPrintOrder, type ActionState } from "@/app/actions/printing";
import { Button, Input, Label, Select, Textarea } from "@/components/ui";

export function PrintForm() {
  const [state, action, pending] = useActionState<ActionState, FormData>(
    createPrintOrder,
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

      <div>
        <Label htmlFor="service_type">Service</Label>
        <Select id="service_type" name="service_type" defaultValue="document">
          <option value="document">Document printing</option>
          <option value="poster">Poster</option>
          <option value="banner">Banner</option>
          <option value="business_card">Business cards</option>
          <option value="photo">Photo printing</option>
        </Select>
      </div>
      <div>
        <Label htmlFor="description">Description / instructions</Label>
        <Textarea id="description" name="description" placeholder="e.g. A4, double-sided, bound…" />
      </div>
      <div className="grid gap-4 sm:grid-cols-2">
        <div>
          <Label htmlFor="copies">Copies</Label>
          <Input id="copies" name="copies" type="number" min={1} defaultValue={1} />
        </div>
        <div className="flex items-end pb-2">
          <label className="flex items-center gap-2 text-[14px] text-[var(--color-body-strong)]">
            <input type="checkbox" name="color" className="h-4 w-4 rounded border-[var(--color-hairline-strong)]" />
            Color printing
          </label>
        </div>
      </div>
      <p className="text-[13px] text-[var(--color-muted)]">
        You&apos;ll receive an estimated price on submission. Final pricing is
        confirmed at collection.
      </p>
      <Button type="submit" disabled={pending} className="w-full h-11">
        {pending ? "Submitting…" : "Submit print order"}
      </Button>
    </form>
  );
}
