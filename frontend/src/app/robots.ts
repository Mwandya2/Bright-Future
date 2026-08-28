import type { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      // Keep private / auth-only areas out of search results.
      disallow: ["/admin", "/admin-login", "/dashboard", "/api/"],
    },
    sitemap: "https://brightfuture.best/sitemap.xml",
    host: "https://brightfuture.best",
  };
}
