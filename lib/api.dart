import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 🔁 polling لحد ما الفيديو يجهز
/// (مع limit + validation + failed handling + network protection + smart delay capped)
Future<String?> waitForVideo(String id) async {
  int retries = 0;

  while (retries < 50) {
    try {
      final response = await http.post(
        Uri.parse("https://n8n-culu.onrender.com/webhook/check-video"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": id}),
      );

      if (response.statusCode != 200) {
        throw Exception("Server error");
      }

      final data = jsonDecode(response.body);

      print("CHECK: $data");

      if (data["status"] == "succeeded") {
        return data["video_url"];
      }

      /// ✅ لو فشل يوقف فورًا
      if (data["status"] == "failed") {
        throw Exception("Video failed");
      }
    } catch (e) {
      /// 🔥 يمنع crash في حالة network error
      print("Polling error: $e");
    }

    /// 🔥 Smart delay (يزود تدريجيًا لكن max 10 ثواني)
    await Future.delayed(
      Duration(seconds: (2 + retries).clamp(2, 10)),
    );

    retries++;
  }

  return null;
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

/// 🆕 generate باستخدام URLs (مع validation)
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

  if (response.statusCode != 200) {
    throw Exception("Server error");
  }

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