/**
 * Design Tokens
 * Centralized design system variables for colors, fonts, spacing, etc.
 */

export const colors = {
  primary: {
    50: '#fff0f5',
    100: '#ffe1ec',
    200: '#ffc8dc',
    300: '#ff9bc3',
    400: '#ff6b9d',
    500: '#ff3d7f',
    600: '#e8245f',
    700: '#c41a4a',
    800: '#a2183f',
    900: '#871939',
    DEFAULT: '#ff6b9d',
  },
  secondary: {
    50: '#fff1f2',
    100: '#ffe4e6',
    200: '#fecdd3',
    300: '#fda4af',
    400: '#fb7185',
    500: '#f43f5e',
    600: '#e11d48',
    700: '#be123c',
    800: '#9f1239',
    900: '#881337',
    DEFAULT: '#fda4af',
  },
  accent: {
    DEFAULT: '#ffd93d',
    dark: '#f0c800',
  },
  // Semantic colors
  success: {
    light: '#d1fae5',
    DEFAULT: '#10b981',
    dark: '#047857',
  },
  warning: {
    light: '#fef3c7',
    DEFAULT: '#f59e0b',
    dark: '#b45309',
  },
  error: {
    light: '#fee2e2',
    DEFAULT: '#ef4444',
    dark: '#b91c1c',
  },
  info: {
    light: '#dbeafe',
    DEFAULT: '#3b82f6',
    dark: '#1d4ed8',
  },
  // Neutral colors
  gray: {
    50: '#f9fafb',
    100: '#f3f4f6',
    200: '#e5e7eb',
    300: '#d1d5db',
    400: '#9ca3af',
    500: '#6b7280',
    600: '#4b5563',
    700: '#374151',
    800: '#1f2937',
    900: '#111827',
  },
} as const;

export const fontFamily = {
  sans: ['Pretendard', 'system-ui', 'sans-serif'],
  display: ['Pretendard', 'system-ui', 'sans-serif'],
  mono: ['JetBrains Mono', 'Consolas', 'monospace'],
} as const;

export const fontSize = {
  xs: ['0.75rem', { lineHeight: '1rem' }],
  sm: ['0.875rem', { lineHeight: '1.25rem' }],
  base: ['1rem', { lineHeight: '1.5rem' }],
  lg: ['1.125rem', { lineHeight: '1.75rem' }],
  xl: ['1.25rem', { lineHeight: '1.75rem' }],
  '2xl': ['1.5rem', { lineHeight: '2rem' }],
  '3xl': ['1.875rem', { lineHeight: '2.25rem' }],
  '4xl': ['2.25rem', { lineHeight: '2.5rem' }],
  '5xl': ['3rem', { lineHeight: '1.16' }],
  '6xl': ['3.75rem', { lineHeight: '1.1' }],
} as const;

export const spacing = {
  section: '5rem',
  container: '1280px',
} as const;

export const borderRadius = {
  button: '0.75rem',
  card: '1rem',
  badge: '9999px',
} as const;

export const animation = {
  float: 'float 6s ease-in-out infinite',
  'pulse-slow': 'pulse 4s ease-in-out infinite',
  'fade-in': 'fadeIn 0.5s ease-out',
  'slide-up': 'slideUp 0.5s ease-out',
} as const;

export const keyframes = {
  float: {
    '0%, 100%': { transform: 'translateY(0)' },
    '50%': { transform: 'translateY(-20px)' },
  },
  fadeIn: {
    '0%': { opacity: '0' },
    '100%': { opacity: '1' },
  },
  slideUp: {
    '0%': { opacity: '0', transform: 'translateY(20px)' },
    '100%': { opacity: '1', transform: 'translateY(0)' },
  },
} as const;

// Export all tokens
export const designTokens = {
  colors,
  fontFamily,
  fontSize,
  spacing,
  borderRadius,
  animation,
  keyframes,
} as const;
