'use client'

import { motion } from 'framer-motion'
import {
  Heart,
  CreditCard,
  Calendar,
  Users,
  Trophy,
  MessageSquare,
} from 'lucide-react'

const features = [
  {
    icon: Heart,
    title: '직접 후원',
    description:
      '좋아하는 아이돌에게 직접 후원하고 응원 메시지를 전달하세요. 익명 후원도 가능합니다.',
    color: 'from-pink-500 to-rose-500',
  },
  {
    icon: CreditCard,
    title: '구독 멤버십',
    description:
      '월간 구독으로 독점 콘텐츠, 팬미팅 우선권 등 특별한 혜택을 받아보세요.',
    color: 'from-rose-400 to-rose-500',
  },
  {
    icon: Trophy,
    title: '크라우드 펀딩',
    description:
      '앨범 발매, 콘서트 개최 등 아이돌의 꿈을 함께 이루어주세요.',
    color: 'from-amber-500 to-orange-500',
  },
  {
    icon: Calendar,
    title: '메이드카페 예약',
    description:
      '인기 메이드카페 방문 예약을 앱에서 간편하게! 실시간 좌석 확인.',
    color: 'from-emerald-500 to-teal-500',
  },
  {
    icon: Users,
    title: '팬 커뮤니티',
    description:
      '같은 아이돌을 응원하는 팬들과 소통하고 정보를 공유하세요.',
    color: 'from-blue-500 to-cyan-500',
  },
  {
    icon: MessageSquare,
    title: '실시간 알림',
    description:
      '아이돌의 새 게시물, 라이브 방송, 이벤트 소식을 실시간으로 받아보세요.',
    color: 'from-rose-400 to-rose-300',
  },
]

const containerVariants = {
  hidden: {},
  visible: {
    transition: {
      staggerChildren: 0.1,
    },
  },
}

const itemVariants = {
  hidden: { opacity: 0, y: 30 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.5 } },
}

export default function Features() {
  return (
    <section id="features" className="section-padding bg-gray-50">
      <div className="max-w-7xl mx-auto">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <span className="inline-block px-4 py-2 bg-primary/10 rounded-full text-primary font-medium text-sm mb-4">
            주요 기능
          </span>
          <h2 className="text-3xl md:text-4xl font-bold mb-4">
            팬과 아이돌을 연결하는
            <br />
            <span className="gradient-text">특별한 기능들</span>
          </h2>
          <p className="text-gray-600 max-w-2xl mx-auto">
            아이돌 서포트는 팬과 아이돌 모두에게 필요한 다양한 기능을 제공합니다.
          </p>
        </motion.div>

        {/* Features Grid */}
        <motion.div
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          className="grid md:grid-cols-2 lg:grid-cols-3 gap-8"
        >
          {features.map((feature, index) => (
            <motion.div
              key={feature.title}
              variants={itemVariants}
              className="card group hover:scale-105 transition-transform duration-300"
            >
              <div
                className={`w-14 h-14 rounded-2xl bg-gradient-to-r ${feature.color} flex items-center justify-center mb-6 group-hover:scale-110 transition-transform duration-300`}
              >
                <feature.icon className="w-7 h-7 text-white" />
              </div>
              <h3 className="text-xl font-bold mb-3 text-gray-900">{feature.title}</h3>
              <p className="text-gray-600 leading-relaxed">
                {feature.description}
              </p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  )
}
