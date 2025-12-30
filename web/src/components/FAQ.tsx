'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronDown } from 'lucide-react'

const faqs = [
  {
    question: '아이돌 서포트는 무료인가요?',
    answer:
      '네, 앱 다운로드와 기본 기능 사용은 완전 무료입니다. 후원이나 구독 멤버십은 원하실 때만 이용하시면 됩니다.',
  },
  {
    question: '후원금은 어떻게 전달되나요?',
    answer:
      '후원금은 플랫폼 수수료(10%)를 제외하고 아이돌에게 직접 전달됩니다. 매월 정산되며, 투명한 정산 내역을 확인할 수 있습니다.',
  },
  {
    question: '아이돌로 등록하려면 어떻게 하나요?',
    answer:
      '앱 내 "아이돌 등록" 메뉴에서 신청서를 작성해주세요. 본인 인증과 간단한 심사를 거쳐 등록이 완료됩니다.',
  },
  {
    question: '결제 수단은 무엇이 있나요?',
    answer:
      '신용카드, 체크카드, 간편결제(카카오페이, 네이버페이), 무통장입금 등 다양한 결제 수단을 지원합니다.',
  },
  {
    question: '구독을 취소할 수 있나요?',
    answer:
      '언제든지 구독을 취소할 수 있습니다. 취소 후에도 결제한 기간까지는 혜택을 이용할 수 있습니다.',
  },
  {
    question: '개인정보는 안전하게 보호되나요?',
    answer:
      '네, 모든 개인정보는 암호화되어 안전하게 보호됩니다. 개인정보보호법을 준수하며, 제3자에게 정보를 제공하지 않습니다.',
  },
]

export default function FAQ() {
  const [openIndex, setOpenIndex] = useState<number | null>(0)

  return (
    <section id="faq" className="section-padding bg-gray-50">
      <div className="max-w-3xl mx-auto">
        {/* Section Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-12"
        >
          <span className="inline-block px-4 py-2 bg-primary/10 rounded-full text-primary font-medium text-sm mb-4">
            FAQ
          </span>
          <h2 className="text-3xl md:text-4xl font-bold mb-4">
            자주 묻는 질문
          </h2>
          <p className="text-gray-600">
            궁금한 점이 있으신가요? 자주 묻는 질문을 확인해보세요.
          </p>
        </motion.div>

        {/* FAQ Items */}
        <div className="space-y-4">
          {faqs.map((faq, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.05 }}
              className="bg-white rounded-2xl shadow-sm overflow-hidden"
            >
              <button
                onClick={() => setOpenIndex(openIndex === index ? null : index)}
                className="w-full px-6 py-5 text-left flex items-center justify-between hover:bg-gray-50 transition-colors"
              >
                <span className="font-semibold text-gray-900">
                  {faq.question}
                </span>
                <ChevronDown
                  className={`w-5 h-5 text-gray-500 transition-transform duration-300 ${
                    openIndex === index ? 'rotate-180' : ''
                  }`}
                />
              </button>
              <AnimatePresence>
                {openIndex === index && (
                  <motion.div
                    initial={{ height: 0, opacity: 0 }}
                    animate={{ height: 'auto', opacity: 1 }}
                    exit={{ height: 0, opacity: 0 }}
                    transition={{ duration: 0.3 }}
                    className="overflow-hidden"
                  >
                    <div className="px-6 pb-5 text-gray-600 leading-relaxed">
                      {faq.answer}
                    </div>
                  </motion.div>
                )}
              </AnimatePresence>
            </motion.div>
          ))}
        </div>

        {/* Contact Link */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="text-center mt-12"
        >
          <p className="text-gray-600">
            찾으시는 답변이 없으신가요?{' '}
            <a href="#contact" className="text-primary font-semibold hover:underline">
              문의하기
            </a>
          </p>
        </motion.div>
      </div>
    </section>
  )
}
