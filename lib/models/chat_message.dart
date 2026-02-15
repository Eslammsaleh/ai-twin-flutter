class ChatMessage {
  final String? text;       // Nullable عشان لو الصورة فقط
  final String? imagePath;  // Nullable عشان لو النص فقط
  final bool isUser;
  final DateTime time;

  ChatMessage({
    this.text,
    this.imagePath,
    required this.isUser,
    required this.time,
  });
}
