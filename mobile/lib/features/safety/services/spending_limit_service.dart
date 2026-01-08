import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user spending limits
class SpendingLimitService {
  static const String _dailyLimitKey = 'spending_daily_limit';
  static const String _weeklyLimitKey = 'spending_weekly_limit';
  static const String _monthlyLimitKey = 'spending_monthly_limit';
  static const String _dailySpentKey = 'spending_daily_spent';
  static const String _weeklySpentKey = 'spending_weekly_spent';
  static const String _monthlySpentKey = 'spending_monthly_spent';
  static const String _lastResetDateKey = 'spending_last_reset_date';
  static const String _lastWeekResetKey = 'spending_last_week_reset';
  static const String _lastMonthResetKey = 'spending_last_month_reset';
  static const String _spendingEnabledKey = 'spending_limits_enabled';

  late SharedPreferences _prefs;
  bool _initialized = false;

  static final SpendingLimitService _instance = SpendingLimitService._internal();
  factory SpendingLimitService() => _instance;
  SpendingLimitService._internal();

  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    await _resetIfNeeded();
  }

  /// Check if spending limits are enabled
  bool get isEnabled => _prefs.getBool(_spendingEnabledKey) ?? false;

  /// Enable or disable spending limits
  Future<void> setEnabled(bool enabled) async {
    await _prefs.setBool(_spendingEnabledKey, enabled);
  }

  /// Get current limits
  SpendingLimits getLimits() {
    return SpendingLimits(
      daily: _prefs.getDouble(_dailyLimitKey) ?? 100000,
      weekly: _prefs.getDouble(_weeklyLimitKey) ?? 500000,
      monthly: _prefs.getDouble(_monthlyLimitKey) ?? 1000000,
    );
  }

  /// Set spending limits
  Future<void> setLimits(SpendingLimits limits) async {
    await _prefs.setDouble(_dailyLimitKey, limits.daily);
    await _prefs.setDouble(_weeklyLimitKey, limits.weekly);
    await _prefs.setDouble(_monthlyLimitKey, limits.monthly);
  }

  /// Get current spending
  SpendingStats getSpending() {
    return SpendingStats(
      daily: _prefs.getDouble(_dailySpentKey) ?? 0,
      weekly: _prefs.getDouble(_weeklySpentKey) ?? 0,
      monthly: _prefs.getDouble(_monthlySpentKey) ?? 0,
    );
  }

  /// Check if a transaction is allowed
  SpendingCheckResult checkTransaction(double amount) {
    if (!isEnabled) {
      return SpendingCheckResult(
        allowed: true,
        message: null,
        remainingDaily: double.infinity,
        remainingWeekly: double.infinity,
        remainingMonthly: double.infinity,
      );
    }

    final limits = getLimits();
    final spending = getSpending();

    final remainingDaily = limits.daily - spending.daily;
    final remainingWeekly = limits.weekly - spending.weekly;
    final remainingMonthly = limits.monthly - spending.monthly;

    if (amount > remainingDaily) {
      return SpendingCheckResult(
        allowed: false,
        message: '일일 지출 한도(${_formatCurrency(limits.daily)})를 초과합니다.\n'
            '남은 한도: ${_formatCurrency(remainingDaily)}',
        remainingDaily: remainingDaily,
        remainingWeekly: remainingWeekly,
        remainingMonthly: remainingMonthly,
        limitType: LimitType.daily,
      );
    }

    if (amount > remainingWeekly) {
      return SpendingCheckResult(
        allowed: false,
        message: '주간 지출 한도(${_formatCurrency(limits.weekly)})를 초과합니다.\n'
            '남은 한도: ${_formatCurrency(remainingWeekly)}',
        remainingDaily: remainingDaily,
        remainingWeekly: remainingWeekly,
        remainingMonthly: remainingMonthly,
        limitType: LimitType.weekly,
      );
    }

    if (amount > remainingMonthly) {
      return SpendingCheckResult(
        allowed: false,
        message: '월간 지출 한도(${_formatCurrency(limits.monthly)})를 초과합니다.\n'
            '남은 한도: ${_formatCurrency(remainingMonthly)}',
        remainingDaily: remainingDaily,
        remainingWeekly: remainingWeekly,
        remainingMonthly: remainingMonthly,
        limitType: LimitType.monthly,
      );
    }

    // Warning if approaching limit
    String? warningMessage;
    if (spending.daily + amount > limits.daily * 0.8) {
      warningMessage = '일일 지출 한도의 80%에 도달했습니다.';
    } else if (spending.weekly + amount > limits.weekly * 0.8) {
      warningMessage = '주간 지출 한도의 80%에 도달했습니다.';
    } else if (spending.monthly + amount > limits.monthly * 0.8) {
      warningMessage = '월간 지출 한도의 80%에 도달했습니다.';
    }

    return SpendingCheckResult(
      allowed: true,
      message: warningMessage,
      remainingDaily: remainingDaily - amount,
      remainingWeekly: remainingWeekly - amount,
      remainingMonthly: remainingMonthly - amount,
      isWarning: warningMessage != null,
    );
  }

  /// Record a transaction
  Future<void> recordTransaction(double amount) async {
    await _resetIfNeeded();

    final spending = getSpending();
    await _prefs.setDouble(_dailySpentKey, spending.daily + amount);
    await _prefs.setDouble(_weeklySpentKey, spending.weekly + amount);
    await _prefs.setDouble(_monthlySpentKey, spending.monthly + amount);
  }

  /// Reset daily/weekly/monthly spending if period has passed
  Future<void> _resetIfNeeded() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check daily reset
    final lastResetStr = _prefs.getString(_lastResetDateKey);
    if (lastResetStr != null) {
      final lastReset = DateTime.parse(lastResetStr);
      if (lastReset.isBefore(today)) {
        await _prefs.setDouble(_dailySpentKey, 0);
        debugPrint('Daily spending reset');
      }
    }
    await _prefs.setString(_lastResetDateKey, today.toIso8601String());

    // Check weekly reset (Monday)
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final lastWeekResetStr = _prefs.getString(_lastWeekResetKey);
    if (lastWeekResetStr != null) {
      final lastWeekReset = DateTime.parse(lastWeekResetStr);
      if (lastWeekReset.isBefore(weekStart)) {
        await _prefs.setDouble(_weeklySpentKey, 0);
        debugPrint('Weekly spending reset');
      }
    }
    await _prefs.setString(_lastWeekResetKey, weekStart.toIso8601String());

    // Check monthly reset (1st of month)
    final monthStart = DateTime(now.year, now.month, 1);
    final lastMonthResetStr = _prefs.getString(_lastMonthResetKey);
    if (lastMonthResetStr != null) {
      final lastMonthReset = DateTime.parse(lastMonthResetStr);
      if (lastMonthReset.isBefore(monthStart)) {
        await _prefs.setDouble(_monthlySpentKey, 0);
        debugPrint('Monthly spending reset');
      }
    }
    await _prefs.setString(_lastMonthResetKey, monthStart.toIso8601String());
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(0)}만원';
    }
    return '${amount.toStringAsFixed(0)}원';
  }

  /// Get predefined limit options for UI
  List<LimitOption> getDailyLimitOptions() {
    return [
      LimitOption(amount: 10000, label: '1만원'),
      LimitOption(amount: 30000, label: '3만원'),
      LimitOption(amount: 50000, label: '5만원'),
      LimitOption(amount: 100000, label: '10만원'),
      LimitOption(amount: 200000, label: '20만원'),
      LimitOption(amount: 500000, label: '50만원'),
    ];
  }

  List<LimitOption> getWeeklyLimitOptions() {
    return [
      LimitOption(amount: 50000, label: '5만원'),
      LimitOption(amount: 100000, label: '10만원'),
      LimitOption(amount: 200000, label: '20만원'),
      LimitOption(amount: 500000, label: '50만원'),
      LimitOption(amount: 1000000, label: '100만원'),
    ];
  }

  List<LimitOption> getMonthlyLimitOptions() {
    return [
      LimitOption(amount: 100000, label: '10만원'),
      LimitOption(amount: 300000, label: '30만원'),
      LimitOption(amount: 500000, label: '50만원'),
      LimitOption(amount: 1000000, label: '100만원'),
      LimitOption(amount: 2000000, label: '200만원'),
      LimitOption(amount: 5000000, label: '500만원'),
    ];
  }
}

class SpendingLimits {
  final double daily;
  final double weekly;
  final double monthly;

  const SpendingLimits({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });
}

class SpendingStats {
  final double daily;
  final double weekly;
  final double monthly;

  const SpendingStats({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });
}

class SpendingCheckResult {
  final bool allowed;
  final String? message;
  final double remainingDaily;
  final double remainingWeekly;
  final double remainingMonthly;
  final LimitType? limitType;
  final bool isWarning;

  SpendingCheckResult({
    required this.allowed,
    this.message,
    required this.remainingDaily,
    required this.remainingWeekly,
    required this.remainingMonthly,
    this.limitType,
    this.isWarning = false,
  });
}

enum LimitType { daily, weekly, monthly }

class LimitOption {
  final double amount;
  final String label;

  const LimitOption({
    required this.amount,
    required this.label,
  });
}
