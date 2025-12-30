'use client'

import { motion } from 'framer-motion'
import { Star, Quote } from 'lucide-react'

const testimonials = [
  {
    name: '김민지',
    role: '열정적인 팬',
    content:
      '좋아하는 아이돌을 직접 응원할 수 있어서 너무 좋아요! 후원할 때마다 뿌듯함을 느껴요.',
    avatar: 'M',
    rating: 5,
  },
  {
    name: '이하늘',
    role: '구독 멤버',
    content:
      '구독 멤버십 혜택이 정말 알차요. 독점 콘텐츠랑 팬미팅 우선권까지 완벽합니다!',
    avatar: 'H',
    rating: 5,
  },
  {
    name: '박서연',
    role: '지하 아이돌',
    content:
      '팬분들의 따뜻한 응원 덕분에 더 열심히 활동할 수 있어요. 정말 감사합니다!',
    avatar: 'S',
    rating: 5,
  },
]

export default function Testimonials() {
  return (
    <section className="section-padding bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 text-white">
      <div className="max-w-7xl mx-auto">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <span className="inline-block px-4 py-2 bg-white/10 rounded-full text-primary-300 font-medium text-sm mb-4">
            사용자 후기
          </span>
          <h2 className="text-3xl md:text-4xl font-bold mb-4">
            팬과 아이돌 모두가
            <br />
            <span className="gradient-text">사랑하는 플랫폼</span>
          </h2>
        </motion.div>

        {/* Testimonials Grid */}
        <div className="grid md:grid-cols-3 gap-8">
          {testimonials.map((testimonial, index) => (
            <motion.div
              key={testimonial.name}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              className="bg-white/5 backdrop-blur-lg rounded-2xl p-6 border border-white/10 hover:bg-white/10 transition-colors"
            >
              {/* Quote Icon */}
              <Quote className="w-10 h-10 text-primary/50 mb-4" />

              {/* Content */}
              <p className="text-gray-300 mb-6 leading-relaxed">
                "{testimonial.content}"
              </p>

              {/* Rating */}
              <div className="flex gap-1 mb-4">
                {Array.from({ length: testimonial.rating }).map((_, i) => (
                  <Star
                    key={i}
                    className="w-4 h-4 fill-yellow-400 text-yellow-400"
                  />
                ))}
              </div>

              {/* Author */}
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-gradient-to-r from-primary to-secondary flex items-center justify-center text-white font-bold">
                  {testimonial.avatar}
                </div>
                <div>
                  <div className="font-semibold">{testimonial.name}</div>
                  <div className="text-sm text-gray-400">{testimonial.role}</div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
