import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stitch_smart_church_guide/core/constants/app_colors.dart';
import 'package:stitch_smart_church_guide/models/ai_message.dart';
import 'package:stitch_smart_church_guide/services/ai_assistant_service.dart';
import 'package:stitch_smart_church_guide/services/auth_service.dart';
import 'package:stitch_smart_church_guide/services/location_service.dart';
import 'package:uuid/uuid.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _service = AiAssistantService();
  final _uuid = const Uuid();
  final List<AiMessage> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_service.welcomeMessage());
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _loading) return;

    setState(() {
      _messages.add(AiMessage(
        id: _uuid.v4(),
        role: AiMessageRole.user,
        content: text.trim(),
        timestamp: DateTime.now(),
      ));
      _loading = true;
    });
    _controller.clear();

    final profile = context.read<AuthService>().currentProfile;
    final churches = context.read<LocationService>().churchesWithDistance();

    final response = await _service.respond(text, profile, churches);

    setState(() {
      _messages.add(response);
      _loading = false;
    });

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy, color: AppColors.copticGold),
            SizedBox(width: 8),
            Text('المساعد الذكي'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (_loading && i == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                return _MessageBubble(message: _messages[i]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      hintText: 'اسأل عن كنيسة، قداس، أو اجتماع...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _send(_controller.text),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickChip(label: 'أقرب كنيسة', onTap: () => _send('أين أقرب كنيسة؟')),
                  _QuickChip(label: 'اقترح اجتماع', onTap: () => _send('اقترح اجتماعات لي')),
                  _QuickChip(label: 'مواعيد القداس', onTap: () => _send('مواعيد القداسات')),
                  _QuickChip(label: 'الأديرة', onTap: () => _send('أخبرني عن الأديرة')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final AiMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AiMessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.copticBurgundy
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 4 : 16),
            bottomRight: Radius.circular(isUser ? 16 : 4),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : null,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: onTap,
      ),
    );
  }
}
