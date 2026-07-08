"use client";

import { useRef } from "react";

/**
 * A select that submits its parent form as soon as the value changes.
 * Used in admin tables for inline status updates.
 */
export function StatusSelect({
  name,
  defaultValue,
  options,
}: {
  name: string;
  defaultValue: string;
  options: { value: string; label: string }[];
}) {
  const ref = useRef<HTMLSelectElement>(null);
  return (
    <select
      ref={ref}
      name={name}
      defaultValue={defaultValue}
      onChange={() => ref.current?.form?.requestSubmit()}
      className="h-9 rounded-lg border border-[var(--color-hairline-strong)] bg-white px-2.5 text-[13px] font-medium text-[var(--color-ink)] outline-none focus:border-[var(--color-ink)]"
    >
      {options.map((o) => (
        <option key={o.value} value={o.value}>
          {o.label}
        </option>
      ))}
    </select>
  );
}
