import { NextResponse, type NextRequest } from "next/server";
import { AUTH_COOKIE_NAME } from "@/lib/auth-cookie";
import { isTheAdmin } from "@/lib/admin";

/**
 * Route guard for /dashboard and /admin.
 *
 * Sign-in goes through the Spring Boot API, which returns a JWT that the auth
 * server action stores in the `bf_auth_token` cookie. This reads that cookie.
 *
 * The signature is deliberately NOT verified here. Middleware runs on the Edge
 * runtime, and verifying would mean copying JWT_SECRET into the frontend - a
 * second place for the signing key to leak from. It is not needed, because this
 * guard only decides *which page to render*: every piece of data on those pages
 * is fetched from the Spring API, which does verify the signature and returns
 * 401/403 on a forged or expired token. A forged cookie gets you an empty
 * dashboard shell, never data.
 */
interface JwtClaims {
  sub?: string;
  email?: string;
  role?: string;
  exp?: number;
}

function decodeJwt(token: string): JwtClaims | null {
  try {
    const payload = token.split(".")[1];
    if (!payload) return null;
    // base64url -> base64, then pad to a multiple of 4.
    const b64 = payload.replace(/-/g, "+").replace(/_/g, "/");
    const padded = b64.padEnd(b64.length + ((4 - (b64.length % 4)) % 4), "=");
    return JSON.parse(atob(padded)) as JwtClaims;
  } catch {
    return null;
  }
}

function isExpired(claims: JwtClaims): boolean {
  // `exp` is in seconds. Treat a token with no expiry as invalid rather than
  // eternal.
  if (typeof claims.exp !== "number") return true;
  return claims.exp * 1000 <= Date.now();
}

export function middleware(request: NextRequest) {
  const path = request.nextUrl.pathname;

  // Precise match so /admin-login (the public admin entrance) is NOT guarded.
  const isAdminRoute = path === "/admin" || path.startsWith("/admin/");
  const isProtected = path.startsWith("/dashboard") || isAdminRoute;

  if (!isProtected) {
    return NextResponse.next();
  }

  const token = request.cookies.get(AUTH_COOKIE_NAME)?.value;
  const claims = token ? decodeJwt(token) : null;
  const signedIn = claims !== null && !isExpired(claims);

  if (!signedIn) {
    const url = request.nextUrl.clone();
    // Admin routes send you to the separate admin door; users to /login.
    url.pathname = isAdminRoute ? "/admin-login" : "/login";
    if (!isAdminRoute) url.searchParams.set("redirect", path);
    const response = NextResponse.redirect(url);
    // Clear a stale or malformed token so the user is not bounced forever.
    if (token) response.cookies.delete(AUTH_COOKIE_NAME);
    return response;
  }

  if (isAdminRoute && !isTheAdmin(claims.email, claims.role)) {
    const url = request.nextUrl.clone();
    url.pathname = "/dashboard";
    return NextResponse.redirect(url);
  }

  return NextResponse.next();
}

export const config = {
  matcher: ["/dashboard/:path*", "/admin/:path*", "/admin"],
};
