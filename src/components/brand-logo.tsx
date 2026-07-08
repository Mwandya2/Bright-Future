import Image from "next/image";
import Link from "next/link";

/**
 * Bright Future brand lockup: the BFT emblem + optional wordmark.
 * Used in the nav, footer, dashboard, and auth screens.
 */
export function BrandLogo({
  href = "/" as string | null,
  wordmark = true,
  size = 32,
  textClass = "",
  wordmarkSize = "text-[19px]",
}: {
  href?: string | null;
  wordmark?: boolean;
  size?: number;
  textClass?: string;
  wordmarkSize?: string;
}) {
  const inner = (
    <span className="flex items-center gap-2">
      <Image
        src="/logo.png"
        alt="Bright Future"
        width={size}
        height={size}
        priority
        className="rounded-full"
        style={{ width: size, height: size }}
      />
      {wordmark && (
        <span className={`font-semibold tracking-tight text-[var(--color-ink)] ${wordmarkSize} ${textClass}`}>
          Bright&nbsp;Future
        </span>
      )}
    </span>
  );

  if (!href) return inner;
  return (
    <Link href={href} className="inline-flex items-center">
      {inner}
    </Link>
  );
}
