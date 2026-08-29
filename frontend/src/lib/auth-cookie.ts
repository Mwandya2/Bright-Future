/**
 * The cookie the Spring API's JWT is stored in.
 *
 * This lives on its own, with no imports, because middleware runs on the Edge
 * runtime and cannot load `next/headers` - which api-client.ts imports at
 * module scope. Importing the constant from there pulls the whole module into
 * the middleware bundle and crashes it with MIDDLEWARE_INVOCATION_FAILED.
 */
export const AUTH_COOKIE_NAME = "bf_auth_token";
