import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/chat_message.dart';
import '../../theme/app_colors.dart';
import '../../services/chat_api.dart';

class ChatPage extends StatefulWidget {
  final File? initialImage;
  const ChatPage({super.key, this.initialImage});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialImage != null) {
      _messages.add(
        ChatMessage(
          imagePath: widget.initialImage!.path,
          isUser: true,
          time: DateTime.now(),
        ),
      );
    }

    _messages.add(
      ChatMessage(
        text: "أنا LifeTwin 👋 ابدأ الكلام.",
        isUser: false,
        time: DateTime.now(),
      ),
    );
  }

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

      // رسالة AI فاضية
      _messages.insert(
        0,
        ChatMessage(
          text: "",
          isUser: false,
          time: DateTime.now(),
        ),
      );

      _isTyping = true;
    });

    _controller.clear();

    try {
      String aiText = "";

      await ChatAPI.streamMessage(
        message: userText,

        // 🔥 streaming live
        onData: (chunk) {
          aiText += chunk;

          setState(() {
            _messages[0] = ChatMessage(
              text: aiText,
              isUser: false,
              time: DateTime.now(),
            );
          });
        },

        // 🔥 لما يخلص
        onDone: (finalText) {
          setState(() {
            _messages[0] = ChatMessage(
              text: finalText,
              isUser: false,
              time: DateTime.now(),
            );
            _isTyping = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: "Error connecting to AI",
            isUser: false,
            time: DateTime.now(),
          ),
        );
        _isTyping = false;
      });
    }
  }

  Widget _messageBubble(ChatMessage msg) {
    return Align(
      alignment:
          msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.primary : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: msg.imagePath != null
            ? Image.file(File(msg.imagePath!), width: 200)
            : Text(
                msg.text ?? "",
                style: TextStyle(
                  color: msg.isUser ? Colors.white : Colors.black,
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
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messageBubble(_messages[index]);
              },
            ),
          ),

          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text("AI is thinking..."),
            ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "اكتب رسالة...",
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