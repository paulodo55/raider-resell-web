import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { AuthProvider } from '@/hooks/useAuth'
import { ChatStoreProvider } from '@/hooks/useChatStore'
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
    <html lang="en">
      <body className={inter.className}>
        <AuthProvider>
          <ChatStoreProvider>
            {children}
            <Toaster
              position="top-right"
              toastOptions={{
                duration: 4000,
                style: {
                  background: '#fff',
                  color: '#333',
                  borderRadius: '12px',
                  border: '1px solid #e5e7eb',
                  boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1)',
                },
              }}
            />
          </ChatStoreProvider>
        </AuthProvider>
      </body>
    </html>
  )
} 