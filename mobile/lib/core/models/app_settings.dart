/// Application settings model
///
/// Stores user preferences for the app
class AppSettings {
  final String language;
  final double fontSize;
  final bool notificationsEnabled;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool dataSaverMode;

  const AppSettings({
    this.language = 'ko',
    this.fontSize = 16.0,
    this.notificationsEnabled = true,
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.dataSaverMode = false,
  });

  /// Create settings from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language'] as String? ?? 'ko',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      pushNotificationsEnabled:
          json['pushNotificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled:
          json['emailNotificationsEnabled'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      dataSaverMode: json['dataSaverMode'] as bool? ?? false,
    );
  }

  /// Convert settings to JSON
  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'fontSize': fontSize,
      'notificationsEnabled': notificationsEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'dataSaverMode': dataSaverMode,
    };
  }

  /// Copy settings with updated values
  AppSettings copyWith({
    String? language,
    double? fontSize,
    bool? notificationsEnabled,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? dataSaverMode,
  }) {
    return AppSettings(
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      dataSaverMode: dataSaverMode ?? this.dataSaverMode,
    );
  }

  /// Default settings
  static const AppSettings defaults = AppSettings();

  /// Get language name for display
  String get languageName {
    switch (language) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      default:
        return language;
    }
  }

  /// Get font size label
  String get fontSizeLabel {
    if (fontSize <= 14) return '작게';
    if (fontSize <= 16) return '보통';
    if (fontSize <= 18) return '크게';
    return '매우 크게';
  }
}
