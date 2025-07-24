import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { AuthProvider } from '@/hooks/useAuth'
import { Toaster } from 'react-hot-toast'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Raider ReSell - Texas Tech Marketplace',
  description: 'Buy and sell items within the Texas Tech University community',
  keywords: 'Texas Tech, marketplace, student, buy, sell, university, college',
  authors: [{ name: 'Raider ReSell Team' }],
  openGraph: {
    title: 'Raider ReSell - Texas Tech Marketplace',
    description: 'Buy and sell items within the Texas Tech University community',
    type: 'website',
    locale: 'en_US',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Raider ReSell - Texas Tech Marketplace',
    description: 'Buy and sell items within the Texas Tech University community',
  },
  viewport: 'width=device-width, initial-scale=1',
  themeColor: '#CC092F',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className="h-full">
      <body className={`${inter.className} h-full bg-texas-gray-50 text-texas-gray-900`}>
        <AuthProvider>
          {children}
          <Toaster
            position="top-right"
            toastOptions={{
              duration: 4000,
              style: {
                background: '#fff',
                color: '#212121',
                border: '1px solid #CC092F',
              },
              success: {
                iconTheme: {
                  primary: '#CC092F',
                  secondary: '#fff',
                },
              },
              error: {
                iconTheme: {
                  primary: '#ef4444',
                  secondary: '#fff',
                },
              },
            }}
          />
        </AuthProvider>
      </body>
    </html>
  )
} 