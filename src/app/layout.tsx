import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "CareerCraft Studio | Dynamic Resume & Career Platform",
  description: "Pick a format, answer a few questions, get a resume you can edit and export.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen antialiased">{children}</body>
    </html>
  );
}
