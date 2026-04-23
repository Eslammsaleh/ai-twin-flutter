import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 🔁 polling لحد ما الفيديو يجهز
Future<String?> waitForVideo(String id) async {
  while (true) {
    final response = await http.post(
      Uri.parse("https://n8n-culu.onrender.com/webhook/check-video"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"id": id}),
    );

    final data = jsonDecode(response.body);

    print("CHECK: $data");

    if (data["status"] == "succeeded") {
      return data["video_url"];
    }

    await Future.delayed(const Duration(seconds: 3));
  }
}

/// ☁️ رفع صورة على Cloudinary
Future<String?> uploadToCloudinary(File file) async {
  final url = Uri.parse(
    "https://api.cloudinary.com/v1_1/YOUR_CLOUD_NAME/image/upload",
  );

  var request = http.MultipartRequest('POST', url);

  request.fields['upload_preset'] = 'YOUR_UPLOAD_PRESET';

  request.files.add(
    await http.MultipartFile.fromPath('file', file.path),
  );

  var response = await request.send();
  var resBody = await response.stream.bytesToString();

  final data = jsonDecode(resBody);

  return data['secure_url'];
}

/// 🔊 رفع صوت على Cloudinary
Future<String?> uploadAudio(File file) async {
  final url = Uri.parse(
    "https://api.cloudinary.com/v1_1/YOUR_CLOUD_NAME/raw/upload",
  );

  var request = http.MultipartRequest('POST', url);

  request.fields['upload_preset'] = 'YOUR_UPLOAD_PRESET';

  request.files.add(
    await http.MultipartFile.fromPath('file', file.path),
  );

  var response = await request.send();
  var resBody = await response.stream.bytesToString();

  final data = jsonDecode(resBody);

  return data['secure_url'];
}

/// 🆕 generate باستخدام URLs (بدل رفع ملفات)
Future<Map<String, dynamic>> generateVideoWithUrls({
  required String prompt,
  required List<Map<String, dynamic>> characters,
  required List<Map<String, dynamic>> dialogues,
}) async {
  final response = await http.post(
    Uri.parse("https://n8n-culu.onrender.com/webhook/generate-video"),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "prompt": prompt,
      "characters": characters,
      "dialogues": dialogues,
    }),
  );

  final data = jsonDecode(response.body);
  return data;
}

/// 🎬 generate video (الطريقة القديمة - multipart)
Future<Map<String, dynamic>> generateVideo({
  required String prompt,
  List<Map<String, dynamic>>? charactersData,
  List<Map<String, dynamic>>? dialogues,
}) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("https://n8n-culu.onrender.com/webhook/generate-video"),
    );

    request.fields['prompt'] = prompt;

    if (charactersData != null && charactersData.isNotEmpty) {
      for (int i = 0; i < charactersData.length; i++) {
        final char = charactersData[i];

        if (char["name"] != null) {
          request.fields['characters[$i][name]'] = char["name"];
        }

        if (char["image"] != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'characters[$i][image]',
              char["image"],
            ),
          );
        }

        if (char["audio"] != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'characters[$i][audio]',
              char["audio"],
            ),
          );
        }
      }
    }

    if (dialogues != null && dialogues.isNotEmpty) {
      for (int i = 0; i < dialogues.length; i++) {
        final d = dialogues[i];

        request.fields['dialogues[$i][name]'] = d["name"] ?? "";
        request.fields['dialogues[$i][text]'] = d["text"] ?? "";

        if (d["image"] != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'dialogues[$i][image]',
              d["image"],
            ),
          );
        }

        if (d["audio"] != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'dialogues[$i][audio]',
              d["audio"],
            ),
          );
        }
      }
    }

    var response = await request.send();

    final respStr = await response.stream.bytesToString();
    print("STATUS: ${response.statusCode}");
    print("BODY: $respStr");

    final data = jsonDecode(respStr);

    return data;
  } catch (e) {
    print("ERROR: $e");
    throw Exception(e.toString());
  }
}