'use client'

import { Heart } from 'lucide-react'

const footerLinks = {
  서비스: ['기능 소개', '요금 안내', '아이돌 등록', 'API'],
  지원: ['고객센터', 'FAQ', '이용가이드', '공지사항'],
  회사: ['회사 소개', '채용', '블로그', '뉴스'],
  법률: ['이용약관', '개인정보처리방침', '청소년보호정책'],
}

export default function Footer() {
  return (
    <footer className="bg-gray-900 text-gray-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="grid md:grid-cols-2 lg:grid-cols-6 gap-8">
          {/* Brand */}
          <div className="lg:col-span-2">
            <a href="#" className="flex items-center space-x-2 mb-6">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-r from-primary to-secondary flex items-center justify-center">
                <Heart className="w-6 h-6 text-white" />
              </div>
              <span className="font-bold text-xl text-white">아이돌 서포트</span>
            </a>
            <p className="text-gray-400 mb-6 leading-relaxed">
              팬과 아이돌이 함께 성장하는 플랫폼.
              <br />
              좋아하는 아이돌을 직접 응원하세요.
            </p>
            <div className="flex space-x-4">
              {['twitter', 'instagram', 'youtube', 'facebook'].map((social) => (
                <a
                  key={social}
                  href="#"
                  className="w-10 h-10 rounded-full bg-gray-800 hover:bg-primary flex items-center justify-center transition-colors"
                >
                  <span className="sr-only">{social}</span>
                  <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                    <circle cx="12" cy="12" r="8" />
                  </svg>
                </a>
              ))}
            </div>
          </div>

          {/* Links */}
          {Object.entries(footerLinks).map(([category, links]) => (
            <div key={category}>
              <h3 className="font-semibold text-white mb-4">{category}</h3>
              <ul className="space-y-3">
                {links.map((link) => (
                  <li key={link}>
                    <a
                      href="#"
                      className="text-gray-400 hover:text-primary transition-colors"
                    >
                      {link}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        {/* Bottom */}
        <div className="mt-12 pt-8 border-t border-gray-800">
          <div className="flex flex-col md:flex-row justify-between items-center gap-4">
            <p className="text-gray-500 text-sm">
              &copy; {new Date().getFullYear()} Idol Support. All rights reserved.
            </p>
            <div className="flex items-center gap-4 text-sm text-gray-500">
              <span>주식회사 아이돌서포트</span>
              <span>|</span>
              <span>대표: 홍길동</span>
              <span>|</span>
              <span>사업자등록번호: 123-45-67890</span>
            </div>
          </div>
        </div>
      </div>
    </footer>
  )
}
