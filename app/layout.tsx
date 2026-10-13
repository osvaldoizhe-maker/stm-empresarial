import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "STM Empresarial", description: "Sistema empresarial de mantenimiento multiempresa" };
export default function RootLayout({ children }: Readonly<{children: React.ReactNode}>) {
  return <html lang="es"><body>{children}</body></html>;
}
