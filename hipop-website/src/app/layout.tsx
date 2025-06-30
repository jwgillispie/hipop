import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { Navigation } from "@/components/Navigation";
import { Footer } from "@/components/Footer";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
});

export const metadata: Metadata = {
  title: "HiPop Markets - Discover Local Farmers Markets & Fresh Food",
  description: "Find the best farmers markets near you. Discover fresh, local produce, artisanal foods, and connect with local vendors through the HiPop Markets app.",
  keywords: "farmers markets, local food, fresh produce, farmers market app, local vendors, organic food, artisan markets, handmade goods",
  authors: [{ name: "HiPop Markets" }],
  robots: "index, follow",
  verification: {
    google: "your-google-verification-code",
  },
  openGraph: {
    title: "HiPop Markets - Discover Local Farmers Markets",
    description: "Find the best farmers markets near you with the HiPop Markets app.",
    type: "website",
    siteName: "HiPop Markets",
    url: "https://hipop-markets-website.web.app",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: "HiPop Markets - Discover Local Farmers Markets",
    description: "Find the best farmers markets near you with the HiPop Markets app.",
    site: "@hipopmarkets",
  },
  alternates: {
    canonical: "https://hipop-markets-website.web.app",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "WebApplication",
    "name": "HiPop Markets",
    "description": "Find the best farmers markets near you. Discover fresh, local produce, artisanal foods, and connect with local vendors.",
    "url": "https://hipop-markets-website.web.app",
    "applicationCategory": "BusinessApplication",
    "operatingSystem": "Web",
    "offers": {
      "@type": "Offer",
      "price": "0",
      "priceCurrency": "USD"
    },
    "aggregateRating": {
      "@type": "AggregateRating",
      "ratingValue": "4.8",
      "ratingCount": "1200"
    }
  };

  return (
    <html lang="en" className={inter.variable}>
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }}
        />
      </head>
      <body className="font-sans antialiased bg-white text-gray-900">
        <Navigation />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}
