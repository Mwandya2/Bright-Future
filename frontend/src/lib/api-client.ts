import { cookies } from "next/headers";
import type { ApiResponse } from "./types";

const API_BASE = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080/api";

export const AUTH_COOKIE_NAME = "bf_auth_token";

async function getAuthToken(): Promise<string | null> {
  // Check if executing in Next.js server context
  if (typeof window === "undefined") {
    try {
      const cookieStore = await cookies();
      return cookieStore.get(AUTH_COOKIE_NAME)?.value || null;
    } catch {
      return null;
    }
  } else {
    // Client-side execution
    const match = document.cookie.match(new RegExp(`(^| )${AUTH_COOKIE_NAME}=([^;]+)`));
    return match ? decodeURIComponent(match[2]) : null;
  }
}

interface RequestOptions extends RequestInit {
  token?: string;
  params?: Record<string, string | number | boolean | undefined>;
}

async function request<T>(endpoint: string, options: RequestOptions = {}): Promise<ApiResponse<T>> {
  const { token, params, ...fetchOptions } = options;
  
  const resolvedToken = token || (await getAuthToken());

  let url = `${API_BASE}${endpoint.startsWith("/") ? endpoint : `/${endpoint}`}`;
  
  if (params) {
    const searchParams = new URLSearchParams();
    Object.entries(params).forEach(([key, val]) => {
      if (val !== undefined && val !== null) {
        searchParams.append(key, String(val));
      }
    });
    const qs = searchParams.toString();
    if (qs) {
      url += (url.includes("?") ? "&" : "?") + qs;
    }
  }

  const headers = new Headers(fetchOptions.headers || {});
  if (!headers.has("Content-Type") && !(fetchOptions.body instanceof FormData)) {
    headers.set("Content-Type", "application/json");
  }
  if (resolvedToken && !headers.has("Authorization")) {
    headers.set("Authorization", `Bearer ${resolvedToken}`);
  }

  try {
    const res = await fetch(url, {
      ...fetchOptions,
      headers,
      cache: fetchOptions.cache || "no-store",
    });

    const data: ApiResponse<T> = await res.json().catch(() => ({
      success: res.ok,
      message: res.statusText,
    }));

    if (!res.ok) {
      return {
        success: false,
        message: data.message || `Request failed with status ${res.status}`,
      };
    }

    return data;
  } catch (err: unknown) {
    const errorMsg = err instanceof Error ? err.message : "Network error";
    return {
      success: false,
      message: `Failed to communicate with API server (${errorMsg})`,
    };
  }
}

export const apiClient = {
  get: <T>(endpoint: string, options?: RequestOptions) =>
    request<T>(endpoint, { ...options, method: "GET" }),

  post: <T>(endpoint: string, body?: unknown, options?: RequestOptions) =>
    request<T>(endpoint, {
      ...options,
      method: "POST",
      body: body instanceof FormData ? body : JSON.stringify(body),
    }),

  put: <T>(endpoint: string, body?: unknown, options?: RequestOptions) =>
    request<T>(endpoint, {
      ...options,
      method: "PUT",
      body: body instanceof FormData ? body : JSON.stringify(body),
    }),

  patch: <T>(endpoint: string, body?: unknown, options?: RequestOptions) =>
    request<T>(endpoint, {
      ...options,
      method: "PATCH",
      body: body ? JSON.stringify(body) : undefined,
    }),

  delete: <T>(endpoint: string, options?: RequestOptions) =>
    request<T>(endpoint, { ...options, method: "DELETE" }),
};
