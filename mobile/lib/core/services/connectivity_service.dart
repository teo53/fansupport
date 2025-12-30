import 'dart:async';
import 'package:flutter/foundation.dart';

/// 연결 상태
enum ConnectivityStatus {
  connected,
  disconnected,
  unknown,
}

/// 연결 상태 관리 서비스
/// 네트워크 연결 상태를 모니터링하고 변경 시 알림
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  // 현재 연결 상태
  ConnectivityStatus _status = ConnectivityStatus.unknown;
  ConnectivityStatus get status => _status;

  // 연결 상태 변경 스트림
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  // 연결됨 여부
  bool get isConnected => _status == ConnectivityStatus.connected;

  /// 초기화
  Future<void> initialize() async {
    // TODO: connectivity_plus 패키지 연동
    // 현재는 항상 연결됨으로 가정 (데모용)
    _status = ConnectivityStatus.connected;
    debugPrint('[ConnectivityService] Initialized: $_status');
  }

  /// 연결 상태 변경
  void updateStatus(ConnectivityStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(newStatus);
      debugPrint('[ConnectivityService] Status changed: $_status');
    }
  }

  /// 연결 확인
  Future<bool> checkConnectivity() async {
    // TODO: 실제 네트워크 연결 확인
    // 현재는 항상 true 반환 (데모용)
    return true;
  }

  /// 정리
  void dispose() {
    _statusController.close();
  }
}

/// 전역 인스턴스
final connectivityService = ConnectivityService();
