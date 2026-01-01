import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';
import 'logger_service.dart';
import 'secure_storage_service.dart';
import 'connectivity_service.dart';
import 'analytics_service.dart';

/// 앱 초기화 단계
enum InitializationStep {
  config,
  services,
  auth,
  data,
  ui,
}

/// 앱 초기화 결과
class InitializationResult {
  final bool success;
  final String? errorMessage;
  final InitializationStep? failedStep;

  InitializationResult.success()
      : success = true,
        errorMessage = null,
        failedStep = null;

  InitializationResult.failure(this.errorMessage, this.failedStep)
      : success = false;
}

/// 앱 초기화 서비스
/// 앱 시작 시 필요한 모든 초기화 작업 수행
class AppInitializer {
  static final AppInitializer _instance = AppInitializer._internal();
  factory AppInitializer() => _instance;
  AppInitializer._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// 전체 초기화 수행
  Future<InitializationResult> initialize() async {
    if (_isInitialized) {
      logger.w('AppInitializer', 'Already initialized, skipping');
      return InitializationResult.success();
    }

    final stopwatch = Stopwatch()..start();

    try {
      // 1. 설정 초기화
      await _initializeConfig();

      // 2. 서비스 초기화
      await _initializeServices();

      // 3. 인증 상태 확인
      await _initializeAuth();

      // 4. 초기 데이터 로드
      await _initializeData();

      // 5. UI 설정
      await _initializeUI();

      _isInitialized = true;
      stopwatch.stop();

      logger.i('AppInitializer',
        'Initialization complete in ${stopwatch.elapsedMilliseconds}ms');

      return InitializationResult.success();
    } catch (e, stackTrace) {
      logger.e('AppInitializer', 'Initialization failed',
        error: e, stackTrace: stackTrace);
      return InitializationResult.failure(
        e.toString(),
        InitializationStep.config,
      );
    }
  }

  /// 설정 초기화
  Future<void> _initializeConfig() async {
    logger.d('AppInitializer', 'Initializing config...');

    // 환경 설정
    AppConfig.setEnvironment(AppEnvironment.development);
    AppConfig.setDemoMode(true); // 데모 모드 활성화

    // 설정 출력 (디버그용)
    AppConfig.printConfig();
  }

  /// 서비스 초기화
  Future<void> _initializeServices() async {
    logger.d('AppInitializer', 'Initializing services...');

    // 로거 설정
    logger.setMinLevel(LogLevel.verbose);

    // 연결 서비스
    await connectivityService.initialize();

    // 분석 서비스
    await analytics.initialize();
  }

  /// 인증 상태 초기화
  Future<void> _initializeAuth() async {
    logger.d('AppInitializer', 'Checking auth state...');

    final storage = SecureStorageService();
    final isLoggedIn = await storage.isLoggedIn();

    logger.d('AppInitializer', 'User logged in: $isLoggedIn');

    // TODO: 토큰 유효성 검증
    // TODO: 자동 로그인 처리
  }

  /// 초기 데이터 로드
  Future<void> _initializeData() async {
    logger.d('AppInitializer', 'Loading initial data...');

    // TODO: 필수 데이터 프리로드
    // - 사용자 프로필
    // - 앱 설정
    // - 캐시된 데이터
  }

  /// UI 초기화
  Future<void> _initializeUI() async {
    logger.d('AppInitializer', 'Initializing UI...');

    // 시스템 UI 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // 화면 방향 설정
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// 리셋 (테스트용)
  void reset() {
    _isInitialized = false;
  }
}

/// 전역 인스턴스
final appInitializer = AppInitializer();
