# PIPO Mobile App

Flutter-based mobile application for the PIPO platform (Underground Idol & Maid Cafe Fan Support Platform)

## Prerequisites

- Flutter 3.24.5+ (Stable channel)
- Dart 3.0+
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

## Installation

```bash
# Install dependencies
flutter pub get

# Generate code (Riverpod, Freezed)
dart run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run
```

## Building

```bash
# Android APK (Debug)
flutter build apk --debug

# Android APK (Release)
flutter build apk --release

# iOS (macOS only)
flutter build ios --release
```

## Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit with your values
# Key variables:
# - API_URL: Backend API endpoint
# - STRIPE_KEY: Stripe publishable key
# - ENV: development/staging/production
```

### Build with Environment Variables

```bash
# Development
flutter run --dart-define=ENV=development --dart-define=API_URL=http://localhost:3000

# Production
flutter build apk --release \
  --dart-define=ENV=production \
  --dart-define=API_URL=https://api.pipo.com \
  --dart-define=STRIPE_KEY=pk_live_xxx
```

## Architecture

- **State Management**: Riverpod 3.x (Notifier API)
- **Routing**: GoRouter
- **Network**: Dio with interceptors
- **Storage**: Flutter Secure Storage
- **Code Generation**: build_runner, freezed, riverpod_generator

## Key Features

### Error Handling
- Typed exceptions (NetworkException, ServerException, etc.)
- User-friendly Korean error messages
- Automatic JWT token refresh on 401

### Performance
- Cached network images
- ListView.builder for efficient scrolling
- Const constructors for widget optimization

### UI/UX
- Dark mode support
- Custom design system (PipoColors, PipoTypography, PipoSpacing)
- Smooth animations and transitions
- Responsive layouts (max-width 480px)

## Project Structure

```
lib/
├── core/               # Core functionality
│   ├── constants/     # App constants
│   ├── network/       # API client, exceptions
│   ├── providers/     # Global providers (theme, settings)
│   ├── theme/         # Design system
│   └── utils/         # Utilities
├── features/          # Feature modules
│   ├── auth/         # Authentication
│   ├── home/         # Home screen
│   ├── profile/      # User profiles
│   ├── support/      # Support/donations
│   ├── subscription/ # Subscriptions
│   ├── campaign/     # Crowdfunding
│   ├── booking/      # Maid cafe bookings
│   ├── community/    # Posts & comments
│   ├── wallet/       # Wallet & transactions
│   ├── live/         # Live streaming
│   └── chat/         # Messaging
└── shared/           # Shared models & widgets
```

## Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

## Troubleshooting

### Build Errors

**Kotlin version issues:**
- Ensure `kotlin_version = '2.1.0'` in `android/build.gradle`
- Clear cache: `flutter clean && flutter pub get`

**Gradle errors:**
- Use Gradle 8.12: Check `gradle-wrapper.properties`
- Use Java 17: `java -version`

### Runtime Errors

**Network errors:**
- Check API_URL in environment variables
- Verify backend is running
- Check network permissions in AndroidManifest.xml

## License

MIT
