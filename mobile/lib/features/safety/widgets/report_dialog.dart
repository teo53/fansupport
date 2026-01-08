import 'package:flutter/material.dart';
import '../../../core/theme/design_system.dart';
import '../services/report_service.dart';

/// Dialog for reporting users or content
class ReportDialog extends StatefulWidget {
  final ReportType type;
  final String targetId;
  final String? targetName;
  final Function(ReportResult) onReportSubmitted;

  const ReportDialog({
    super.key,
    required this.type,
    required this.targetId,
    this.targetName,
    required this.onReportSubmitted,
  });

  static Future<void> show({
    required BuildContext context,
    required ReportType type,
    required String targetId,
    String? targetName,
    required String token,
  }) async {
    final reportService = ReportService();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportDialog(
        type: type,
        targetId: targetId,
        targetName: targetName,
        onReportSubmitted: (result) async {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor:
                  result.success ? PipoColors.success : PipoColors.error,
            ),
          );
        },
      ),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportReason? _selectedReason;
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.type) {
      case ReportType.user:
        return '사용자 신고';
      case ReportType.replyRequest:
        return '요청 신고';
      case ReportType.reply:
        return '답장 신고';
      case ReportType.post:
        return '게시글 신고';
      case ReportType.message:
        return '메시지 신고';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: PipoColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(PipoRadius.xl)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: PipoSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PipoColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(PipoSpacing.lg),
            child: Row(
              children: [
                Text(
                  _title,
                  style: PipoTypography.heading2.copyWith(
                    color: PipoColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: PipoColors.textSecondary,
                ),
              ],
            ),
          ),

          if (widget.targetName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(PipoSpacing.md),
                decoration: BoxDecoration(
                  color: PipoColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(PipoRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: PipoColors.textSecondary,
                    ),
                    const SizedBox(width: PipoSpacing.sm),
                    Expanded(
                      child: Text(
                        '${widget.targetName} 신고',
                        style: PipoTypography.bodyMedium.copyWith(
                          color: PipoColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: PipoSpacing.md),

          // Reason selection
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: PipoSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '신고 사유를 선택해주세요',
                    style: PipoTypography.titleSmall.copyWith(
                      color: PipoColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PipoSpacing.md),

                  ...ReportReason.values.map((reason) => _buildReasonTile(reason)),

                  const SizedBox(height: PipoSpacing.lg),

                  // Additional details
                  Text(
                    '추가 설명 (선택)',
                    style: PipoTypography.titleSmall.copyWith(
                      color: PipoColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PipoSpacing.sm),
                  TextField(
                    controller: _detailsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '구체적인 상황을 설명해주세요...',
                      hintStyle: PipoTypography.bodyMedium.copyWith(
                        color: PipoColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: PipoColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(PipoRadius.md),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(PipoSpacing.md),
                    ),
                    style: PipoTypography.bodyMedium.copyWith(
                      color: PipoColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: PipoSpacing.lg),
                ],
              ),
            ),
          ),

          // Submit button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(PipoSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedReason != null && !_isSubmitting
                      ? _submitReport
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PipoColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: PipoSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(PipoRadius.md),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          '신고하기',
                          style: PipoTypography.titleSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonTile(ReportReason reason) {
    final isSelected = _selectedReason == reason;

    return GestureDetector(
      onTap: () => setState(() => _selectedReason = reason),
      child: Container(
        margin: const EdgeInsets.only(bottom: PipoSpacing.sm),
        padding: const EdgeInsets.all(PipoSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? PipoColors.error.withOpacity(0.05)
              : PipoColors.surfaceVariant,
          borderRadius: BorderRadius.circular(PipoRadius.md),
          border: Border.all(
            color: isSelected ? PipoColors.error : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? PipoColors.error : PipoColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: PipoColors.error,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: PipoSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason.displayName,
                    style: PipoTypography.titleSmall.copyWith(
                      color: PipoColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reason.description,
                    style: PipoTypography.labelSmall.copyWith(
                      color: PipoColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) return;

    setState(() => _isSubmitting = true);

    // In a real app, get token from auth provider
    const token = 'mock_token';

    final reportService = ReportService();
    final result = await reportService.submitReport(
      token: token,
      type: widget.type,
      targetId: widget.targetId,
      reason: _selectedReason!,
      details: _detailsController.text.isNotEmpty
          ? _detailsController.text
          : null,
    );

    setState(() => _isSubmitting = false);
    widget.onReportSubmitted(result);
  }
}

/// Quick block confirmation dialog
class BlockConfirmDialog extends StatelessWidget {
  final String userName;
  final VoidCallback onConfirm;

  const BlockConfirmDialog({
    super.key,
    required this.userName,
    required this.onConfirm,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String userName,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => BlockConfirmDialog(
        userName: userName,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: PipoColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PipoRadius.lg),
      ),
      title: Text(
        '$userName 차단',
        style: PipoTypography.heading2.copyWith(
          color: PipoColors.textPrimary,
        ),
      ),
      content: Text(
        '이 사용자를 차단하면 더 이상 메시지를 받거나 보낼 수 없습니다. 차단은 설정에서 해제할 수 있습니다.',
        style: PipoTypography.bodyMedium.copyWith(
          color: PipoColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            '취소',
            style: PipoTypography.titleSmall.copyWith(
              color: PipoColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: PipoColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PipoRadius.sm),
            ),
          ),
          child: Text(
            '차단',
            style: PipoTypography.titleSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
