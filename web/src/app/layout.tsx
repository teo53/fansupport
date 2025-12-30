import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: '아이돌 서포트 - 지하 아이돌 & 메이드카페 후원 플랫폼',
  description: '좋아하는 아이돌과 메이드를 응원하세요. 후원, 구독, 펀딩, 예약까지 한번에!',
  keywords: ['아이돌', '메이드카페', '후원', '팬덤', '구독', '펀딩'],
  openGraph: {
    title: '아이돌 서포트',
    description: '지하 아이돌 & 메이드카페 팬덤 후원 플랫폼',
    type: 'website',
    locale: 'ko_KR',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ko">
      <body className="antialiased">{children}</body>
    </html>
  )
}
