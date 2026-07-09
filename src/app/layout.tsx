import type { Metadata } from "next";
import { Inter } from "next/font/google";
// Splash screen disabled — re-enable by uncommenting this import and the
// <SplashScreen /> usage in the body below.
// import { SplashScreen } from "@/components/splash-screen";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  weight: ["300", "400", "500", "600", "700", "800"],
  variable: "--font-inter",
  display: "swap",
});

export const metadata: Metadata = {
  metadataBase: new URL("https://brightfuture.best"),
  title: {
    default: "Bright Future Digital Hub — Empowering Digital Futures",
    template: "%s · Bright Future",
  },
  description:
    "A complete digital empowerment ecosystem: ICT training, computer-lab bookings, digital printing, freelance services, and business support — all in one platform.",
  keywords: [
    "ICT training",
    "digital skills",
    "computer lab",
    "digital printing",
    "e-learning",
    "Bright Future",
  ],
  openGraph: {
    title: "Bright Future Digital Hub",
    description: "Learn. Connect. Grow. Your gateway to ICT excellence.",
    url: "https://brightfuture.best",
    siteName: "Bright Future",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Bright Future Digital Hub",
    description: "Learn. Connect. Grow. Your gateway to ICT excellence.",
  },
  alternates: { canonical: "/" },
  robots: { index: true, follow: true },
  // Set GOOGLE_SITE_VERIFICATION in the environment to the code Google gives
  // you (Search Console → HTML tag method) to auto-verify ownership.
  verification: process.env.GOOGLE_SITE_VERIFICATION
    ? { google: process.env.GOOGLE_SITE_VERIFICATION }
    : undefined,
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={inter.variable}>
      <body className="min-h-full antialiased">
        {/* <SplashScreen /> */}
        {children}
      </body>
    </html>
  );
}
