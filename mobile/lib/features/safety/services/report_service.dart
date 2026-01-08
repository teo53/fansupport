import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';

/// Service for blocking users and reporting content
class ReportService {
  final String baseUrl = ApiConfig.baseUrl;

  /// Block a user
  Future<bool> blockUser({
    required String userId,
    required String token,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/block'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (reason != null) 'reason': reason,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Unblock a user
  Future<bool> unblockUser({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId/block'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  /// Get blocked users list
  Future<List<BlockedUser>> getBlockedUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/blocked'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => BlockedUser.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Report content or user
  Future<ReportResult> submitReport({
    required String token,
    required ReportType type,
    required String targetId,
    required ReportReason reason,
    String? details,
    List<String>? evidenceUrls,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'type': type.name,
          'targetId': targetId,
          'reason': reason.name,
          if (details != null) 'details': details,
          if (evidenceUrls != null) 'evidenceUrls': evidenceUrls,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ReportResult(
          success: true,
          reportId: data['id'],
          message: '신고가 접수되었습니다. 검토 후 조치하겠습니다.',
        );
      } else {
        return ReportResult(
          success: false,
          message: '신고 접수에 실패했습니다. 다시 시도해 주세요.',
        );
      }
    } catch (e) {
      return ReportResult(
        success: false,
        message: '네트워크 오류가 발생했습니다.',
      );
    }
  }
}

class BlockedUser {
  final String id;
  final String displayName;
  final String? profileImageUrl;
  final DateTime blockedAt;

  BlockedUser({
    required this.id,
    required this.displayName,
    this.profileImageUrl,
    required this.blockedAt,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'],
      displayName: json['displayName'] ?? json['nickname'] ?? 'Unknown',
      profileImageUrl: json['profileImageUrl'],
      blockedAt: DateTime.parse(json['blockedAt']),
    );
  }
}

class ReportResult {
  final bool success;
  final String? reportId;
  final String message;

  ReportResult({
    required this.success,
    this.reportId,
    required this.message,
  });
}

enum ReportType {
  user,
  replyRequest,
  reply,
  post,
  message,
}

enum ReportReason {
  spam,
  harassment,
  inappropriateContent,
  scam,
  impersonation,
  copyrightViolation,
  privacyViolation,
  other,
}

extension ReportReasonExtension on ReportReason {
  String get displayName {
    switch (this) {
      case ReportReason.spam:
        return '스팸/광고';
      case ReportReason.harassment:
        return '괴롭힘/따돌림';
      case ReportReason.inappropriateContent:
        return '부적절한 콘텐츠';
      case ReportReason.scam:
        return '사기/금전 요구';
      case ReportReason.impersonation:
        return '사칭';
      case ReportReason.copyrightViolation:
        return '저작권 침해';
      case ReportReason.privacyViolation:
        return '개인정보 침해';
      case ReportReason.other:
        return '기타';
    }
  }

  String get description {
    switch (this) {
      case ReportReason.spam:
        return '원치 않는 광고나 반복적인 메시지';
      case ReportReason.harassment:
        return '욕설, 위협, 또는 반복적인 괴롭힘';
      case ReportReason.inappropriateContent:
        return '선정적, 폭력적, 또는 불쾌한 콘텐츠';
      case ReportReason.scam:
        return '금전을 요구하거나 사기 행위';
      case ReportReason.impersonation:
        return '다른 사람 또는 크리에이터 사칭';
      case ReportReason.copyrightViolation:
        return '무단으로 타인의 저작물 사용';
      case ReportReason.privacyViolation:
        return '동의 없이 개인정보 공개';
      case ReportReason.other:
        return '위에 해당하지 않는 기타 문제';
    }
  }
}
