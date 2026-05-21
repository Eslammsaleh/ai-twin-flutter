// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ChatAPI {
//   static const String baseUrl =
//       "https://formal-carolina-polar-constitutes.trycloudflare.com";

//   /// 🔥 Streaming Chat (Optimized)
//   static Future<void> streamMessage({
//     required String message,
//     required Function(String chunk) onData,
//     required Function(String fullText) onDone,
//     Function(String error)? onError,
//   }) async {
//     try {
//       final request = http.Request(
//         "POST",
//         Uri.parse("$baseUrl/chat_stream"),
//       );

//       request.headers["Content-Type"] = "application/json";
//       request.body = jsonEncode({"question": message});

//       final response = await request.send();

//       // ❌ لو السيرفر مش OK
//       if (response.statusCode != 200) {
//         onError?.call("Server error: ${response.statusCode}");
//         return;
//       }

//       String fullText = "";

//       response.stream.transform(utf8.decoder).listen(
//         (chunk) {
//           fullText += chunk;

//           // 🔥 نبعت chunk بس (أسرع)
//           onData(chunk);
//         },
//         onDone: () {
//           onDone(fullText);
//         },
//         onError: (e) {
//           onError?.call(e.toString());
//         },
//         cancelOnError: true,
//       );
//     } catch (e) {
//       onError?.call(e.toString());
//     }
//   }
// }