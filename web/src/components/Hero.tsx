'use client'

import { motion } from 'framer-motion'
import { Heart, Star, Users, Sparkles } from 'lucide-react'

export default function Hero() {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden bg-gradient-to-br from-pink-50 via-purple-50 to-white">
      {/* Background Decorations */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-primary/10 rounded-full blur-3xl" />
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-secondary/10 rounded-full blur-3xl" />

        {/* Floating Icons */}
        <motion.div
          animate={{ y: [0, -20, 0] }}
          transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut' }}
          className="absolute top-1/4 left-1/4 text-primary/30"
        >
          <Heart className="w-12 h-12" />
        </motion.div>
        <motion.div
          animate={{ y: [0, 20, 0] }}
          transition={{ duration: 5, repeat: Infinity, ease: 'easeInOut' }}
          className="absolute top-1/3 right-1/4 text-secondary/30"
        >
          <Star className="w-10 h-10" />
        </motion.div>
        <motion.div
          animate={{ y: [0, -15, 0] }}
          transition={{ duration: 6, repeat: Infinity, ease: 'easeInOut' }}
          className="absolute bottom-1/3 left-1/3 text-accent/50"
        >
          <Sparkles className="w-8 h-8" />
        </motion.div>
      </div>

      <div className="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-32">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Text Content */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8 }}
            className="text-center lg:text-left"
          >
            <div className="inline-flex items-center px-4 py-2 bg-primary/10 rounded-full text-primary font-medium text-sm mb-6">
              <Sparkles className="w-4 h-4 mr-2" />
              새로운 팬덤 문화의 시작
            </div>

            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold leading-tight mb-6">
              좋아하는
              <br />
              <span className="gradient-text">아이돌</span>을
              <br />
              응원하세요
            </h1>

            <p className="text-lg md:text-xl text-gray-600 mb-8 max-w-xl">
              지하 아이돌, 메이드카페 멤버를 직접 후원하고
              <br className="hidden md:block" />
              특별한 혜택을 받아보세요. 팬과 아이돌이 함께 성장하는 플랫폼.
            </p>

            <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
              <a href="#download" className="btn-primary text-lg px-8 py-4">
                무료로 시작하기
              </a>
              <a
                href="#features"
                className="btn-secondary text-lg px-8 py-4"
              >
                자세히 알아보기
              </a>
            </div>

            {/* Stats */}
            <div className="flex items-center justify-center lg:justify-start gap-8 mt-12">
              <div className="text-center">
                <div className="text-3xl font-bold gradient-text">10K+</div>
                <div className="text-sm text-gray-500">활성 팬</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold gradient-text">500+</div>
                <div className="text-sm text-gray-500">등록 아이돌</div>
              </div>
              <div className="text-center">
                <div className="text-3xl font-bold gradient-text">1억+</div>
                <div className="text-sm text-gray-500">누적 후원</div>
              </div>
            </div>
          </motion.div>

          {/* Phone Mockup */}
          <motion.div
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="relative flex justify-center"
          >
            <div className="relative">
              {/* Phone Frame */}
              <div className="relative w-72 h-[580px] bg-gray-900 rounded-[3rem] p-3 shadow-2xl">
                <div className="absolute top-4 left-1/2 transform -translate-x-1/2 w-20 h-6 bg-gray-900 rounded-full z-10" />
                <div className="w-full h-full bg-gradient-to-br from-primary via-pink-400 to-secondary rounded-[2.5rem] overflow-hidden">
                  {/* App UI Preview */}
                  <div className="p-6 pt-10">
                    <div className="text-white text-lg font-semibold mb-4">
                      인기 아이돌
                    </div>
                    {[1, 2, 3].map((i) => (
                      <div
                        key={i}
                        className="flex items-center gap-3 bg-white/20 backdrop-blur rounded-xl p-3 mb-3"
                      >
                        <div className="w-12 h-12 rounded-full bg-white/30 flex items-center justify-center">
                          <Users className="w-6 h-6 text-white" />
                        </div>
                        <div className="flex-1">
                          <div className="h-3 w-24 bg-white/50 rounded mb-2" />
                          <div className="h-2 w-16 bg-white/30 rounded" />
                        </div>
                        <Heart className="w-5 h-5 text-white" />
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              {/* Floating Card */}
              <motion.div
                animate={{ y: [0, -10, 0] }}
                transition={{ duration: 3, repeat: Infinity }}
                className="absolute -right-8 top-20 bg-white rounded-2xl shadow-xl p-4"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-r from-primary to-secondary flex items-center justify-center">
                    <Heart className="w-5 h-5 text-white" />
                  </div>
                  <div>
                    <div className="text-sm font-semibold">후원 완료!</div>
                    <div className="text-xs text-gray-500">5,000원 후원</div>
                  </div>
                </div>
              </motion.div>

              {/* Floating Card 2 */}
              <motion.div
                animate={{ y: [0, 10, 0] }}
                transition={{ duration: 4, repeat: Infinity }}
                className="absolute -left-8 bottom-32 bg-white rounded-2xl shadow-xl p-4"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-r from-accent-dark to-accent flex items-center justify-center">
                    <Star className="w-5 h-5 text-white" />
                  </div>
                  <div>
                    <div className="text-sm font-semibold">구독 중</div>
                    <div className="text-xs text-gray-500">3명의 아이돌</div>
                  </div>
                </div>
              </motion.div>
            </div>
          </motion.div>
        </div>
      </div>

      {/* Scroll Indicator */}
      <motion.div
        animate={{ y: [0, 10, 0] }}
        transition={{ duration: 2, repeat: Infinity }}
        className="absolute bottom-8 left-1/2 transform -translate-x-1/2"
      >
        <div className="w-6 h-10 border-2 border-gray-300 rounded-full flex justify-center">
          <div className="w-1.5 h-3 bg-gray-300 rounded-full mt-2" />
        </div>
      </motion.div>
    </section>
  )
}
