import type { Metadata } from "next";
import { Inter, EB_Garamond } from "next/font/google";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

const garamond = EB_Garamond({
  subsets: ["latin"],
  weight: ["400", "500"],
  variable: "--font-garamond",
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
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${inter.variable} ${garamond.variable}`}>
      <body className="min-h-full antialiased">{children}</body>
    </html>
  );
}
