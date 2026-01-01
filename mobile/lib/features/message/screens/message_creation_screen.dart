import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/models/idol_model.dart';

class MessageCreationScreen extends StatefulWidget {
  final IdolModel idol;

  const MessageCreationScreen({super.key, required this.idol});

  @override
  State<MessageCreationScreen> createState() => _MessageCreationScreenState();
}

class _MessageCreationScreenState extends State<MessageCreationScreen> {
  final TextEditingController _controller = TextEditingController();

  void _insertTemplate() {
    final text = _controller.text;
    final selection = _controller.selection;
    final newText =
        text.replaceRange(selection.start, selection.end, '{fanName}');
    _controller.value = TextEditingValue(
      text: newText,
      selection:
          TextSelection.collapsed(offset: selection.start + '{fanName}'.length),
    );
  }

  void _sendBroadcast() {
    if (_controller.text.isEmpty) return;

    // Simulate sending
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message sent to 12,405 fans!'),
        backgroundColor: Colors.green,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Broadcast',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _sendBroadcast,
            child: Text('Send',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Fan Targeting Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(' To: All Subscribers (12k)',
                      style: TextStyle(color: Colors.grey[800])),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Input
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText:
                      'Write your message...\nUse {fanName} to mention fans by name!',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),

            // Toolbar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _insertTemplate,
                    icon: const Icon(Icons.alternate_email, size: 18),
                    label: const Text('Insert {fanName}'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary),
                  ),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.image_outlined), onPressed: () {}),
                  IconButton(
                      icon: const Icon(Icons.mic_none_outlined),
                      onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
