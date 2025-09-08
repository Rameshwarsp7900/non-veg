import './globals.css'
import { Inter } from 'next/font/google'
import { Metadata } from 'next'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: {
    default: 'Veg/Non-Veg Decision Calendar',
    template: '%s | Veg/Non-Veg Calendar'
  },
  description: 'A comprehensive calendar app for managing dietary restrictions based on Hindu traditions, cultural practices, and personal preferences. Make informed decisions about vegetarian and non-vegetarian food choices.',
  keywords: [
    'veg',
    'non-veg', 
    'vegetarian',
    'calendar',
    'hindu',
    'dietary restrictions',
    'festivals',
    'food choices',
    'cultural traditions',
    'hanuman',
    'ganesh chaturthi',
    'navratri'
  ],
  authors: [{ name: 'Veg/Non-Veg Calendar Team' }],
  creator: 'Veg/Non-Veg Calendar',
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000'),
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: '/',
    siteName: 'Veg/Non-Veg Decision Calendar',
    title: 'Veg/Non-Veg Decision Calendar',
    description: 'Manage your dietary choices based on Hindu traditions and personal preferences',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'Veg/Non-Veg Decision Calendar',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Veg/Non-Veg Decision Calendar',
    description: 'Manage your dietary choices based on Hindu traditions and personal preferences',
    images: ['/og-image.png'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: process.env.GOOGLE_SITE_VERIFICATION,
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <div className="min-h-screen bg-gray-50">
          {children}
        </div>
      </body>
    </html>
  )
}