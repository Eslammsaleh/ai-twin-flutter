class ChatMessage {

  final String? text;

  final bool isUser;

  final DateTime time;

  final String type;

  final List<dynamic>? options;

  final List<dynamic>? tips;

  ChatMessage({

    required this.text,

    required this.isUser,

    required this.time,

    required this.type,

    this.options,

    this.tips,
  });
}