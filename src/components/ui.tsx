import * as React from "react";
import Link from "next/link";

export function cn(...parts: (string | false | null | undefined)[]) {
  return parts.filter(Boolean).join(" ");
}

/* ─── Button ─── */
type ButtonVariant = "primary" | "outline" | "ghost" | "dark";
const buttonBase =
  "inline-flex items-center justify-center gap-2 rounded-full font-medium text-[15px] leading-none transition-colors disabled:opacity-50 disabled:pointer-events-none px-5 h-10 cursor-pointer";
const buttonVariants: Record<ButtonVariant, string> = {
  primary:
    "bg-[var(--color-primary)] text-white hover:bg-[var(--color-primary-active)]",
  outline:
    "bg-white text-[var(--color-primary)] border border-[var(--color-primary)] hover:bg-[var(--color-primary-subtle)]",
  ghost: "bg-transparent text-[var(--color-primary)] hover:bg-[var(--color-primary-subtle)]",
  dark: "bg-white text-[var(--color-ink)] hover:bg-[var(--color-canvas-soft)]",
};

export function Button({
  variant = "primary",
  className,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & { variant?: ButtonVariant }) {
  return (
    <button className={cn(buttonBase, buttonVariants[variant], className)} {...props} />
  );
}

export function ButtonLink({
  variant = "primary",
  className,
  href,
  children,
  ...props
}: React.AnchorHTMLAttributes<HTMLAnchorElement> & {
  variant?: ButtonVariant;
  href: string;
}) {
  return (
    <Link
      href={href}
      className={cn(buttonBase, buttonVariants[variant], className)}
      {...props}
    >
      {children}
    </Link>
  );
}

/* ─── Card ─── */
export function Card({
  className,
  ...props
}: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        "rounded-[12px] bg-white border border-[var(--color-hairline)] shadow-[0_1px_3px_rgba(0,55,112,0.06)]",
        className,
      )}
      {...props}
    />
  );
}

/* ─── Badge ─── */
export function Badge({
  className,
  children,
}: {
  className?: string;
  children: React.ReactNode;
}) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full bg-[var(--color-primary-subtle)] px-2.5 py-1 text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--color-primary-deep)]",
        className,
      )}
    >
      {children}
    </span>
  );
}

/* ─── Form fields ─── */
export function Label({
  className,
  ...props
}: React.LabelHTMLAttributes<HTMLLabelElement>) {
  return (
    <label
      className={cn(
        "block text-[13px] font-medium text-[var(--color-body-strong)] mb-1.5",
        className,
      )}
      {...props}
    />
  );
}

const fieldBase =
  "w-full rounded-md bg-white border border-[var(--color-hairline-input,#a8c3de)] px-3 py-2.5 text-[15px] text-[var(--color-ink)] placeholder:text-[var(--color-muted-soft)] outline-none focus:border-[var(--color-primary)] focus:ring-1 focus:ring-[var(--color-primary)] transition";

export function Input({
  className,
  ...props
}: React.InputHTMLAttributes<HTMLInputElement>) {
  return <input className={cn(fieldBase, "h-11", className)} {...props} />;
}

export function Textarea({
  className,
  ...props
}: React.TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return <textarea className={cn(fieldBase, "min-h-24", className)} {...props} />;
}

export function Select({
  className,
  children,
  ...props
}: React.SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <select className={cn(fieldBase, "h-11 appearance-none pr-10", className)} {...props}>
      {children}
    </select>
  );
}

/* ─── Section heading ─── */
export function SectionLabel({ children }: { children: React.ReactNode }) {
  return (
    <span className="text-[12px] font-semibold uppercase tracking-[0.096em] text-[var(--color-primary-deep)]">
      {children}
    </span>
  );
}
