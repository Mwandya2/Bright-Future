"use client";

import { useActionState } from "react";
import { createBooking, type ActionState } from "@/app/actions/bookings";
import { Button, Input, Label, Select } from "@/components/ui";

export function BookingForm() {
  const [state, action, pending] = useActionState<ActionState, FormData>(
    createBooking,
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
        <Label htmlFor="workstation_type">Workstation</Label>
        <Select id="workstation_type" name="workstation_type" defaultValue="computer">
          <option value="computer">Computer workstation</option>
          <option value="gaming">Gaming workstation</option>
          <option value="research">Research workstation</option>
          <option value="printing_station">Printing station</option>
        </Select>
      </div>
      <div className="grid gap-4 sm:grid-cols-2">
        <div>
          <Label htmlFor="booking_date">Date</Label>
          <Input id="booking_date" name="booking_date" type="date" required />
        </div>
        <div>
          <Label htmlFor="start_time">Start time</Label>
          <Input id="start_time" name="start_time" type="time" required />
        </div>
      </div>
      <div>
        <Label htmlFor="duration_hours">Duration (hours)</Label>
        <Select id="duration_hours" name="duration_hours" defaultValue="1">
          {[1, 2, 3, 4].map((h) => (
            <option key={h} value={h}>{h} hour{h > 1 ? "s" : ""}</option>
          ))}
        </Select>
      </div>
      <div>
        <Label htmlFor="notes">Notes (optional)</Label>
        <Input id="notes" name="notes" placeholder="Anything we should prepare?" />
      </div>
      <Button type="submit" disabled={pending} className="w-full h-11">
        {pending ? "Requesting…" : "Request booking"}
      </Button>
    </form>
  );
}
