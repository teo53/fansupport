import type { Metadata, Viewport } from 'next'
import './globals.css'

// SEO Configuration
const siteName = '아이돌 서포트'
const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || 'https://idol-support.com'

export const metadata: Metadata = {
  // Basic metadata
  title: {
    default: '아이돌 서포트 - 지하 아이돌 & 메이드카페 후원 플랫폼',
    template: '%s | 아이돌 서포트',
  },
  description: '좋아하는 아이돌과 메이드를 응원하세요. 후원, 구독, 펀딩, 예약까지 한번에! 팬과 크리에이터를 연결하는 새로운 후원 플랫폼입니다.',
  keywords: [
    '아이돌',
    '메이드카페',
    '후원',
    '팬덤',
    '구독',
    '펀딩',
    '크라우드펀딩',
    '지하 아이돌',
    '인디 아이돌',
    '팬 서포트',
    'idol support',
    'maid cafe',
  ],
  authors: [{ name: 'Idol Support Team' }],
  creator: 'Idol Support',
  publisher: 'Idol Support',

  // Canonical URL
  metadataBase: new URL(siteUrl),
  alternates: {
    canonical: '/',
    languages: {
      'ko-KR': '/ko',
      'en-US': '/en',
      'ja-JP': '/ja',
    },
  },

  // Open Graph
  openGraph: {
    title: '아이돌 서포트 - 지하 아이돌 & 메이드카페 후원 플랫폼',
    description: '좋아하는 아이돌과 메이드를 응원하세요. 후원, 구독, 펀딩, 예약까지 한번에!',
    type: 'website',
    locale: 'ko_KR',
    alternateLocale: ['en_US', 'ja_JP'],
    siteName: siteName,
    url: siteUrl,
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: '아이돌 서포트 - 팬과 크리에이터를 연결하는 후원 플랫폼',
      },
    ],
  },

  // Twitter Card
  twitter: {
    card: 'summary_large_image',
    title: '아이돌 서포트 - 지하 아이돌 & 메이드카페 후원 플랫폼',
    description: '좋아하는 아이돌과 메이드를 응원하세요. 후원, 구독, 펀딩, 예약까지 한번에!',
    images: ['/og-image.png'],
    creator: '@idolsupport',
  },

  // App specific
  applicationName: siteName,
  appleWebApp: {
    capable: true,
    statusBarStyle: 'default',
    title: siteName,
  },
  formatDetection: {
    telephone: false,
  },

  // Robots
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

  // Icons
  icons: {
    icon: '/favicon.ico',
    shortcut: '/favicon-16x16.png',
    apple: '/apple-touch-icon.png',
  },

  // Manifest
  manifest: '/manifest.json',
}

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 5,
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#ff6b9d' },
    { media: '(prefers-color-scheme: dark)', color: '#1f2937' },
  ],
}

// Structured Data for SEO (JSON-LD)
const jsonLd = {
  '@context': 'https://schema.org',
  '@type': 'WebApplication',
  name: siteName,
  description: '좋아하는 아이돌과 메이드를 응원하세요. 후원, 구독, 펀딩, 예약까지 한번에!',
  url: siteUrl,
  applicationCategory: 'Entertainment',
  operatingSystem: 'Any',
  offers: {
    '@type': 'Offer',
    price: '0',
    priceCurrency: 'KRW',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ko" suppressHydrationWarning>
      <head>
        {/* Preconnect to external domains */}
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />

        {/* JSON-LD Structured Data */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body className="antialiased bg-white text-gray-900">
        {children}
      </body>
    </html>
  )
}
