import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/chat_message.dart';
import '../../services/assistant_api.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadStartMessage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // =========================
  // SCROLL
  // =========================

  void scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 100),
      () {
        // حماية مضافة: التأكد من أن الـ Widget ما زال موجوداً والـ controller متصل
        if (!mounted) return;
        
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  // =========================
  // START MESSAGE
  // =========================

  Future<void> loadStartMessage() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await AssistantAPI.startAssistant();

      // حماية مضافة: الخروج فوراً إذا غادر المستخدم الصفحة أثناء جلب البيانات
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: response["message"].toString(),
            isUser: false,
            time: DateTime.now(),
            type: response["type"].toString(),
            options: response["options"],
            tips: response["tips"],
          ),
        );
        isLoading = false;
      });

      scrollToBottom();
    } catch (e) {
      // حماية مضافة: في حالة حدوث خطأ بعد مغادرة الصفحة
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: "حدث خطأ أثناء الاتصال بالسيرفر",
            isUser: false,
            time: DateTime.now(),
            type: "error",
          ),
        );
        isLoading = false;
      });
    }
  }

  // =========================
  // SEND CHOICE
  // =========================

  Future<void> sendChoice(String id, String title) async {
    setState(() {
      _messages.add(
        ChatMessage(
          text: title,
          isUser: true,
          time: DateTime.now(),
          type: "user",
        ),
      );
      isLoading = true;
    });

    scrollToBottom();

    try {
      final response = await AssistantAPI.sendChoice(id);

      // حماية مضافة
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: response["message"].toString(),
            isUser: false,
            time: DateTime.now(),
            type: response["type"].toString(),
            options: response["options"],
            tips: response["tips"],
          ),
        );
        isLoading = false;
      });

      scrollToBottom();
    } catch (e) {
      // حماية مضافة
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: "حدث خطأ أثناء الاتصال بالسيرفر",
            isUser: false,
            time: DateTime.now(),
            type: "error",
          ),
        );
        isLoading = false;
      });

      scrollToBottom();
    }
  }

  // =========================
  // SEND MESSAGE
  // =========================

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          time: DateTime.now(),
          type: "user",
        ),
      );
      isLoading = true;
    });

    scrollToBottom();

    try {
      final response = await AssistantAPI.sendMessage(text);

      // حماية مضافة
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: response["message"].toString(),
            isUser: false,
            time: DateTime.now(),
            type: response["type"].toString(),
            options: response["options"],
            tips: response["tips"],
          ),
        );
        isLoading = false;
      });

      scrollToBottom();
    } catch (e) {
      // حماية مضافة
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: "حدث خطأ أثناء الاتصال بالسيرفر",
            isUser: false,
            time: DateTime.now(),
            type: "error",
          ),
        );
        isLoading = false;
      });

      scrollToBottom();
    }
  }

  // =========================
  // MESSAGE BUBBLE
  // =========================

  Widget messageBubble(ChatMessage msg) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    Color bubbleColor = theme.cardColor;
    Color textColor = theme.textTheme.bodyMedium?.color ?? Colors.white;

    if (msg.isUser) {
      bubbleColor = colors.primary;
      textColor = Colors.white;
    }

    if (msg.type == "error") {
      bubbleColor = Colors.red.shade700;
      textColor = Colors.white;
    }

    if (msg.type == "tutorial") {
      bubbleColor = Colors.blue.shade700;
      textColor = Colors.white;
    }

    if (msg.type == "example") {
      bubbleColor = Colors.green.shade700;
      textColor = Colors.white;
    }

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text ?? "",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: textColor,
              ),
            ),
            // =========================
            // TIPS
            // =========================
            if ((msg.tips ?? []).isNotEmpty)
              ...(msg.tips ?? []).map(
                (dynamic tip) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "💡 ${tip.toString()}",
                      style: TextStyle(
                        color: colors.tertiary,
                        fontSize: 14,
                      ),
                    ),
                  );
                },
              ),
            // =========================
            // OPTIONS
            // =========================
            if ((msg.options ?? []).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (msg.options ?? []).map<Widget>(
                    (dynamic option) {
                      final data = option as Map<String, dynamic>;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                sendChoice(
                                  data["id"].toString(),
                                  data["title"].toString(),
                                );
                              },
                        child: Text(
                          data["title"].toString(),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            const SizedBox(
              height: 8,
            ),
            // =========================
            // TIME
            // =========================
            Text(
              DateFormat.Hm().format(msg.time),
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // LOADING BUBBLE
  // =========================

  Widget loadingBubble() {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              "AI is thinking...",
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          "AI Cinematic Assistant",
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: _messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (isLoading && index == _messages.length) {
                  return loadingBubble();
                }
                return messageBubble(_messages[index]);
              },
            ),
          ),
          // =========================
          // INPUT
          // =========================
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "اكتب المشهد السينمائي...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) {
                      if (!isLoading) {
                        sendMessage();
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: isLoading ? null : sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
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