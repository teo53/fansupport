'use client'

import { motion } from 'framer-motion'
import { Download, Search, Heart, Gift } from 'lucide-react'

const steps = [
  {
    icon: Download,
    step: '01',
    title: '앱 다운로드',
    description: 'App Store 또는 Google Play에서 무료로 다운로드하세요.',
  },
  {
    icon: Search,
    step: '02',
    title: '아이돌 찾기',
    description: '좋아하는 아이돌이나 메이드카페를 검색해보세요.',
  },
  {
    icon: Heart,
    step: '03',
    title: '후원하기',
    description: '마음을 담은 후원으로 응원의 마음을 전달하세요.',
  },
  {
    icon: Gift,
    step: '04',
    title: '혜택 받기',
    description: '구독 멤버십으로 독점 콘텐츠와 특별한 혜택을 누리세요.',
  },
]

export default function HowItWorks() {
  return (
    <section id="how-it-works" className="section-padding">
      <div className="max-w-7xl mx-auto">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <span className="inline-block px-4 py-2 bg-secondary/10 rounded-full text-secondary font-medium text-sm mb-4">
            이용 방법
          </span>
          <h2 className="text-3xl md:text-4xl font-bold mb-4">
            쉽고 간단하게
            <br />
            <span className="gradient-text">시작하세요</span>
          </h2>
          <p className="text-gray-600 max-w-2xl mx-auto">
            복잡한 과정 없이 4단계로 아이돌 후원을 시작할 수 있습니다.
          </p>
        </motion.div>

        {/* Steps */}
        <div className="relative">
          {/* Connection Line */}
          <div className="hidden lg:block absolute top-1/2 left-0 right-0 h-0.5 bg-gradient-to-r from-primary via-secondary to-primary transform -translate-y-1/2" />

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {steps.map((step, index) => (
              <motion.div
                key={step.step}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5, delay: index * 0.1 }}
                className="relative"
              >
                <div className="card text-center relative z-10">
                  {/* Step Number */}
                  <div className="absolute -top-4 left-1/2 transform -translate-x-1/2 w-8 h-8 rounded-full bg-gradient-to-r from-primary to-secondary text-white font-bold text-sm flex items-center justify-center shadow-lg">
                    {index + 1}
                  </div>

                  {/* Icon */}
                  <div className="w-16 h-16 mx-auto rounded-2xl bg-gradient-to-r from-primary/10 to-secondary/10 flex items-center justify-center mb-4 mt-4">
                    <step.icon className="w-8 h-8 text-primary" />
                  </div>

                  <h3 className="text-lg font-bold mb-2">{step.title}</h3>
                  <p className="text-gray-600 text-sm">{step.description}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </section>
  )
}
