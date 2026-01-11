import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Phone verification state
class PhoneVerificationState {
  final bool isLoading;
  final bool isCodeSent;
  final bool isVerified;
  final String? error;
  final int? remainingSeconds;

  const PhoneVerificationState({
    this.isLoading = false,
    this.isCodeSent = false,
    this.isVerified = false,
    this.error,
    this.remainingSeconds,
  });

  PhoneVerificationState copyWith({
    bool? isLoading,
    bool? isCodeSent,
    bool? isVerified,
    String? error,
    int? remainingSeconds,
  }) {
    return PhoneVerificationState(
      isLoading: isLoading ?? this.isLoading,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      isVerified: isVerified ?? this.isVerified,
      error: error,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
}

/// Phone verification notifier
class PhoneVerificationNotifier extends Notifier<PhoneVerificationState> {
  Timer? _timer;
  String? _currentPhone;
  String? _verificationCode;
  DateTime? _codeExpiry;

  static const int _codeValiditySeconds = 180; // 3 minutes
  static const int _resendCooldownSeconds = 60; // 1 minute

  @override
  PhoneVerificationState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const PhoneVerificationState();
  }

  /// Send verification code to phone number
  Future<void> sendVerificationCode(String phoneNumber) async {
    // Validate phone number format
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (!RegExp(r'^01[0-9]{8,9}$').hasMatch(cleanPhone)) {
      state = state.copyWith(
        error: '올바른 휴대폰 번호를 입력해주세요',
        isLoading: false,
      );
      return;
    }

    // Check cooldown
    if (state.remainingSeconds != null && state.remainingSeconds! > 0) {
      state = state.copyWith(
        error: '${state.remainingSeconds}초 후에 다시 시도해주세요',
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Generate 6-digit code
      _verificationCode = _generateCode();
      _currentPhone = cleanPhone;
      _codeExpiry = DateTime.now().add(const Duration(seconds: _codeValiditySeconds));

      // In production, send SMS via Supabase Edge Function or external SMS service
      // For now, we'll simulate the SMS sending
      await _sendSmsCode(cleanPhone, _verificationCode!);

      state = state.copyWith(
        isLoading: false,
        isCodeSent: true,
        remainingSeconds: _resendCooldownSeconds,
      );

      // Start cooldown timer
      _startCooldownTimer();

      if (kDebugMode) {
        print('Verification code for $cleanPhone: $_verificationCode');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '인증번호 발송에 실패했습니다. 잠시 후 다시 시도해주세요.',
      );
      if (kDebugMode) {
        print('SMS send error: $e');
      }
    }
  }

  /// Verify the code entered by user
  Future<bool> verifyCode(String code) async {
    if (_verificationCode == null || _codeExpiry == null) {
      state = state.copyWith(error: '인증번호를 먼저 요청해주세요');
      return false;
    }

    // Check expiry
    if (DateTime.now().isAfter(_codeExpiry!)) {
      state = state.copyWith(
        error: '인증번호가 만료되었습니다. 다시 요청해주세요.',
        isCodeSent: false,
      );
      _verificationCode = null;
      return false;
    }

    // Verify code
    if (code.trim() == _verificationCode) {
      state = state.copyWith(
        isVerified: true,
        error: null,
      );

      // Store verification in Supabase (optional)
      await _storeVerification();

      return true;
    } else {
      state = state.copyWith(error: '인증번호가 일치하지 않습니다');
      return false;
    }
  }

  /// Reset verification state
  void reset() {
    _timer?.cancel();
    _verificationCode = null;
    _currentPhone = null;
    _codeExpiry = null;
    state = const PhoneVerificationState();
  }

  /// Generate random 6-digit code
  String _generateCode() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  /// Send SMS code (implement with actual SMS service)
  Future<void> _sendSmsCode(String phone, String code) async {
    // Option 1: Use Supabase Edge Function
    // final supabase = sb.Supabase.instance.client;
    // await supabase.functions.invoke('send-sms', body: {
    //   'phone': phone,
    //   'message': '[PIPO] 인증번호: $code (3분 내 입력)',
    // });

    // Option 2: Use external SMS API (e.g., Twilio, NHN Cloud, etc.)
    // await _twilioService.sendSms(phone, '[PIPO] 인증번호: $code');

    // For development: simulate delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Store successful verification in database
  Future<void> _storeVerification() async {
    if (_currentPhone == null) return;

    try {
      final supabase = sb.Supabase.instance.client;

      // Store in phone_verifications table (if exists)
      // This can be used to check if phone is already verified during registration
      await supabase.from('phone_verifications').upsert({
        'phone': _currentPhone,
        'verified_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      }, onConflict: 'phone');
    } catch (e) {
      // Ignore storage errors - verification is still valid in memory
      if (kDebugMode) {
        print('Failed to store verification: $e');
      }
    }
  }

  /// Start cooldown timer for resend
  void _startCooldownTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.remainingSeconds ?? 0;
      if (remaining <= 1) {
        timer.cancel();
        state = state.copyWith(remainingSeconds: null);
      } else {
        state = state.copyWith(remainingSeconds: remaining - 1);
      }
    });
  }

  /// Get verified phone number
  String? get verifiedPhone => state.isVerified ? _currentPhone : null;
}

/// Provider for phone verification
final phoneVerificationProvider =
    NotifierProvider<PhoneVerificationNotifier, PhoneVerificationState>(() {
  return PhoneVerificationNotifier();
});
