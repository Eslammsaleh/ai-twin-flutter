import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat_message.dart';
import '../../models/twin_mode.dart';
import '../../theme/app_colors.dart';
import '../../providers/twin_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  TwinMode _currentMode = TwinMode.coach;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: "أنا LifeTwin 👋 اختر الوضع وابدأ.",
        isUser: false,
        time: DateTime.now(),
      ),
    );
  }

  String _generateTwinReply(String userText) {
  final twin = Provider.of<TwinProvider>(context, listen: false);

  String stylePrefix;
  if (twin.isAggressive) {
    stylePrefix = "بجرأة: ";
  } else if (twin.isCalm) {
    stylePrefix = "بهدوء: ";
  } else if (twin.isLogical) {
    stylePrefix = "بمنطق: ";
  } else {
    stylePrefix = "بأسلوب متزن: ";
  }

  switch (_currentMode) {
    case TwinMode.coach:
      if (twin.isAggressive) {
        return "${stylePrefix}ردك محتاج يكون أقوى ومباشر… قول النقطة الأساسية الأول وبعدين مثال.";
      } else if (twin.isLogical) {
        return "${stylePrefix}خلّينا ننظم إجابتك: (نقطة) → (سبب) → (مثال) → (نتيجة).";
      } else {
        return "${stylePrefix}إجابتك كويسة، بس حاول تكون أوضح وتستخدم أمثلة.";
      }

    case TwinMode.replay:
      if (twin.isCalm) {
        return "${stylePrefix}الموقف كان محتاج صبر… كان الأفضل تسمع أكتر قبل الرد.";
      } else if (twin.isLogical) {
        return "${stylePrefix}تحليل: قرارك كان سريع؛ لو أخدت 10 ثواني تفكير كانت النتيجة أفضل.";
      } else {
        return "${stylePrefix}تحليل الموقف: هنا كنت محتاج تسمع أكتر قبل الرد.";
      }

    case TwinMode.forecast:
      if (twin.isAggressive) {
        return "${stylePrefix}توقعي: في موقف مشابه هترد بسرعة وبقوة… حاول تهدي قبل الرد بثانية.";
      } else if (twin.isCalm) {
        return "${stylePrefix}توقعي: غالبًا هتتصرف بهدوء… وده ممتاز لو حافظت على وضوحك.";
      } else {
        return "${stylePrefix}توقعي: في موقف مشابه، غالبًا هتتصرف بنفس الأسلوب.";
      }
  }
}


  /// 🔥 Chat مربوط بالتوأم هنا
  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text;

    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: userText,
          isUser: true,
          time: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    /// ✔ كل رسالة = Conversations++
    Provider.of<TwinProvider>(context, listen: false)
        .addConversation();

    _controller.clear();
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: _generateTwinReply(userText),
          isUser: false,
          time: DateTime.now(),
        ),
      );
      _isTyping = false;
    });
  }

  Widget _modeButton(TwinMode mode, String label, IconData icon) {
    final bool isSelected = _currentMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LifeTwin Chat")),
      body: Column(
        children: [
          /// Modes
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _modeButton(TwinMode.coach, "Coach", Icons.school),
                const SizedBox(width: 8),
                _modeButton(TwinMode.replay, "Replay", Icons.history),
                const SizedBox(width: 8),
                _modeButton(
                    TwinMode.forecast, "Forecast", Icons.auto_graph),
              ],
            ),
          ),

          /// Messages
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];

                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text("LifeTwin is thinking..."),
            ),

          /// Input
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "اكتب هنا...",
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
