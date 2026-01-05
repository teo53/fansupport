'use client'

import { motion } from 'framer-motion'
import { Smartphone, Apple, PlayCircle } from 'lucide-react'

export default function Download() {
  return (
    <section id="download" className="section-padding bg-gradient-to-r from-primary via-pink-500 to-secondary">
      <div className="max-w-7xl mx-auto">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Text Content */}
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="text-white text-center lg:text-left"
          >
            <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold mb-6">
              지금 바로
              <br />
              다운로드하세요
            </h2>
            <p className="text-white/80 text-lg mb-8 max-w-lg">
              iOS와 Android 모두 지원합니다.
              <br />
              무료로 다운로드하고 좋아하는 아이돌을 응원해보세요!
            </p>

            {/* Download Buttons */}
            <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
              <a
                href="#"
                className="inline-flex items-center gap-3 bg-black text-white px-6 py-4 rounded-xl hover:bg-gray-900 transition-colors"
              >
                <Apple className="w-8 h-8" />
                <div className="text-left">
                  <div className="text-xs opacity-80">Download on the</div>
                  <div className="font-semibold">App Store</div>
                </div>
              </a>
              <a
                href="#"
                className="inline-flex items-center gap-3 bg-black text-white px-6 py-4 rounded-xl hover:bg-gray-900 transition-colors"
              >
                <PlayCircle className="w-8 h-8" />
                <div className="text-left">
                  <div className="text-xs opacity-80">Get it on</div>
                  <div className="font-semibold">Google Play</div>
                </div>
              </a>
            </div>

            {/* Stats */}
            <div className="flex items-center justify-center lg:justify-start gap-8 mt-10">
              <div>
                <div className="text-3xl font-bold">4.8</div>
                <div className="text-white/70 text-sm">App Store 평점</div>
              </div>
              <div className="w-px h-12 bg-white/20" />
              <div>
                <div className="text-3xl font-bold">50K+</div>
                <div className="text-white/70 text-sm">다운로드</div>
              </div>
            </div>
          </motion.div>

          {/* Phone Mockup */}
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="relative flex justify-center"
          >
            <div className="relative">
              {/* Phone */}
              <div className="relative w-64 h-[520px] bg-gray-900 rounded-[2.5rem] p-2.5 shadow-2xl">
                <div className="absolute top-3 left-1/2 transform -translate-x-1/2 w-16 h-5 bg-gray-900 rounded-full z-10" />
                <div className="w-full h-full bg-white rounded-[2rem] overflow-hidden">
                  <div className="h-full bg-gradient-to-b from-rose-50 to-rose-100 p-4">
                    <div className="h-8 flex items-center justify-center text-sm text-gray-600 font-medium">
                      아이돌 서포트
                    </div>
                    <div className="mt-4 space-y-3">
                      {[1, 2, 3, 4].map((i) => (
                        <div
                          key={i}
                          className="h-16 bg-white rounded-xl shadow-sm flex items-center px-3 gap-3"
                        >
                          <div className="w-10 h-10 rounded-full bg-gradient-to-r from-primary to-secondary" />
                          <div className="flex-1">
                            <div className="h-2.5 w-20 bg-gray-200 rounded mb-1.5" />
                            <div className="h-2 w-14 bg-gray-100 rounded" />
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>

              {/* Decorative Elements */}
              <div className="absolute -top-4 -right-4 w-24 h-24 bg-white/10 rounded-full blur-xl" />
              <div className="absolute -bottom-4 -left-4 w-32 h-32 bg-white/10 rounded-full blur-xl" />
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  )
}
