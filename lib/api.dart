import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> generateVideo(String prompt) async {
  try {
    final response = await http.post(
      Uri.parse(
        "https://primary-production-d4bfc.up.railway.app/webhook/generate-video",
      ),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"prompt": prompt, "api_key": "secret123"}),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    return jsonDecode(response.body);
  } catch (e) {
    print("ERROR: $e");
    throw Exception(e.toString());
  }
}
//
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// Future<Map<String, dynamic>> generateVideo(String prompt) async {
//   try {
//     final response = await http
//         .post(
//           Uri.parse("https://primary-production-d4bfc.up.railway.app/webhook/generate-video"),
//           headers: {"Content-Type": "application/json"},
//           body: jsonEncode({
//             "prompt": prompt,
//             "api_key": "secret123",
//           }),
//         )
//         .timeout(const Duration(seconds: 30));

//     print("STATUS: ${response.statusCode}");
//     print("BODY: ${response.body}");

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception("Server Error: ${response.body}");
//     }
//   } catch (e) {
//     print("ERROR: $e");
//     throw Exception(e.toString());
//   }
// }
