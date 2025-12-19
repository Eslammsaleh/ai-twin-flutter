import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/app_colors.dart'; // تأكد إن المسار ده صح عندك

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  
  // متغير عشان نعرف لو البوت لسه بيفكر او بيكتب
  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {"text": "أهلاً! أنا المساعد الذكي، كيف يمكنني مساعدتك؟", "isUser": false},
  ];

  // دالة الإرسال (خليناها async عشان التعامل مع الانترنت بياخد وقت)
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return; 

    // 1. عرض رسالة المستخدم فوراً ومسح الحقل
    setState(() {
      _messages.insert(0, {"text": text, "isUser": true});
      _isTyping = true; // شغل مؤشر الكتابة
    });
    _controller.clear();

    try {
      // 2. محاكاة للاتصال بالـ API (هنا هتحط كود الـ HTTP الحقيقي)
      // TODO: هنا هتكتب كود الاتصال بالـ API
      // final response = await http.post(....);
      
      await Future.delayed(const Duration(seconds: 2)); // تأخير وهمي كأننا بنكلم سيرفر

      // 3. استقبال الرد وعرضه
      if (mounted) {
        setState(() {
          _messages.insert(0, {
            "text": "هذا رد تجريبي بعد ثانيتين (جاهز لاستبداله برد الـ API الحقيقي).",
            "isUser": false
          });
        });
      }
    } catch (e) {
      // لو حصل خطأ في النت
       if (mounted) {
        setState(() {
           _messages.insert(0, {"text": "حدث خطأ في الاتصال!", "isUser": false});
        });
       }
    } finally {
      // 4. وقف مؤشر الكتابة في كل الأحوال
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      appBar: AppBar(
        title: const Text("Chatbot"),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['isUser'];

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: Radius.circular(isUser ? 15 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 15),
                      ),
                    ),
                    child: Text(
                      message['text'],
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // مؤشر الكتابة (يظهر فقط لما البوت يكون بيحمل)
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "جاري الكتابة...",
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    // بنقفل الكتابة لو البوت لسه بيرد عشان ميبقاش في تداخل
                    enabled: !_isTyping, 
                    decoration: InputDecoration(
                      hintText: "اكتب رسالتك...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _isTyping ? Colors.grey : AppColors.primary,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isTyping ? null : _sendMessage, // تعطيل الزر أثناء التحميل
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