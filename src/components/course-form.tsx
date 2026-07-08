"use client";

import { useActionState } from "react";
import { createCourse, type AdminState } from "@/app/actions/admin";
import { Button, Input, Label, Select, Textarea } from "@/components/ui";

export function CourseForm() {
  const [state, action, pending] = useActionState<AdminState, FormData>(
    createCourse,
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
        <Label htmlFor="title">Course title</Label>
        <Input id="title" name="title" placeholder="Intro to Web Development" required />
      </div>
      <div>
        <Label htmlFor="summary">Summary</Label>
        <Textarea id="summary" name="summary" placeholder="One or two lines describing the course." />
      </div>
      <div className="grid gap-4 sm:grid-cols-2">
        <div>
          <Label htmlFor="category">Category</Label>
          <Select id="category" name="category" defaultValue="web">
            <option value="ict">ICT Fundamentals</option>
            <option value="web">Web Development</option>
            <option value="design">Graphic Design</option>
            <option value="data">Data & AI</option>
            <option value="office">Office & Productivity</option>
            <option value="networking">Networking</option>
          </Select>
        </div>
        <div>
          <Label htmlFor="level">Level</Label>
          <Select id="level" name="level" defaultValue="beginner">
            <option value="beginner">Beginner</option>
            <option value="intermediate">Intermediate</option>
            <option value="advanced">Advanced</option>
          </Select>
        </div>
      </div>
      <div className="grid gap-4 sm:grid-cols-3">
        <div>
          <Label htmlFor="price">Price (TZS)</Label>
          <Input id="price" name="price" type="number" min={0} defaultValue={0} />
        </div>
        <div>
          <Label htmlFor="duration_weeks">Weeks</Label>
          <Input id="duration_weeks" name="duration_weeks" type="number" min={1} defaultValue={4} />
        </div>
        <div>
          <Label htmlFor="cover_gradient">Cover</Label>
          <Select id="cover_gradient" name="cover_gradient" defaultValue="mint">
            <option value="mint">Mint</option>
            <option value="sky">Sky</option>
            <option value="peach">Peach</option>
            <option value="lavender">Lavender</option>
            <option value="rose">Rose</option>
          </Select>
        </div>
      </div>
      <div>
        <Label htmlFor="instructor_name">Instructor</Label>
        <Input id="instructor_name" name="instructor_name" placeholder="e.g. Fatma N." />
      </div>
      <label className="flex items-center gap-2 text-[14px] text-[var(--color-body-strong)]">
        <input type="checkbox" name="is_published" defaultChecked className="h-4 w-4 rounded border-[var(--color-hairline-strong)]" />
        Publish immediately
      </label>
      <Button type="submit" disabled={pending} className="w-full h-11">
        {pending ? "Creating…" : "Create course"}
      </Button>
    </form>
  );
}
