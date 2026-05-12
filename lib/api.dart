import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// ===============================
/// 🌐 API URLs
/// ===============================
const String generateVideoUrl =
    "https://n8n-culu.onrender.com/webhook/generate-video";

const String checkStatusUrl =
    "https://n8n-culu.onrender.com/webhook/check_status_webhook";

const String mergeMovieUrl =
    "https://n8n-culu.onrender.com/webhook/merge-movie";

const String generateVoicesUrl =
    "https://n8n-culu.onrender.com/webhook/generate-voices";

/// ===============================
/// ☁️ CLOUDINARY
/// ===============================
const String cloudName =
    "dfyyydlmk";

const String uploadPreset =
    "life_twin";

/// ===============================
/// ☁️ Upload Image
/// ===============================
Future<String?> uploadImage(
  File file,
) async {
  try {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    var request =
        http.MultipartRequest(
      'POST',
      url,
    );

    request.fields['upload_preset'] =
        uploadPreset;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

    var response =
        await request.send();

    var body =
        await response.stream
            .bytesToString();

    print(
      "UPLOAD IMAGE RESPONSE:",
    );

    print(body);

    if (body.isEmpty) {
      throw Exception(
        "Empty image upload response",
      );
    }

    final data = jsonDecode(body);

    return data["secure_url"];
  } catch (e) {
    print(
      "UPLOAD IMAGE ERROR: $e",
    );

    return null;
  }
}

/// ===============================
/// ☁️ Upload Audio
/// ===============================
Future<String?> uploadAudio(
  File file,
) async {
  try {
    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/video/upload",
    );

    var request =
        http.MultipartRequest(
      'POST',
      url,
    );

    request.fields['upload_preset'] =
        uploadPreset;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

    var response =
        await request.send();

    var body =
        await response.stream
            .bytesToString();

    print(
      "UPLOAD AUDIO RESPONSE:",
    );

    print(body);

    if (body.isEmpty) {
      throw Exception(
        "Empty audio upload response",
      );
    }

    final data = jsonDecode(body);

    return data["secure_url"];
  } catch (e) {
    print(
      "UPLOAD AUDIO ERROR: $e",
    );

    return null;
  }
}

/// ===============================
/// 🎬 GENERATE VIDEO TASKS
/// ===============================
Future<Map<String, dynamic>>
    generateVideoTasks({
  required List<dynamic>
      conversation,
  required List<dynamic>
      characters,
}) async {
  try {
    final response = await http
        .post(
      Uri.parse(
        generateVideoUrl,
      ),
      headers: {
        "Content-Type":
            "application/json",
      },
      body: jsonEncode({
        "conversation":
            conversation,
        "characters":
            characters,
      }),
    )
        .timeout(
      const Duration(
        minutes: 5,
      ),
    );

    print(
      "GENERATE VIDEO STATUS: ${response.statusCode}",
    );

    print(
      "GENERATE VIDEO BODY:",
    );

    print(response.body);

    if (response.body.isEmpty) {
      throw Exception(
        "Server returned empty response",
      );
    }

    return jsonDecode(
      response.body,
    );
  } catch (e) {
    print(
      "GENERATE VIDEO ERROR: $e",
    );

    rethrow;
  }
}

/// ===============================
/// ⏳ CHECK STATUS
/// ===============================
Future<Map<String, dynamic>>
    checkStatus({
  required List<dynamic> tasks,
}) async {
  try {
    final response = await http
        .post(
      Uri.parse(
        checkStatusUrl,
      ),
      headers: {
        "Content-Type":
            "application/json",
      },
      body: jsonEncode({
        "tasks": tasks,
      }),
    )
        .timeout(
      const Duration(
        minutes: 5,
      ),
    );

    print(
      "CHECK STATUS CODE: ${response.statusCode}",
    );

    print(
      "CHECK STATUS BODY:",
    );

    print(response.body);

    if (response.body.isEmpty) {
      throw Exception(
        "Empty check status response",
      );
    }

    return jsonDecode(
      response.body,
    );
  } catch (e) {
    print(
      "CHECK STATUS ERROR: $e",
    );

    rethrow;
  }
}

/// ===============================
/// 🎤 GENERATE VOICES
/// ===============================
Future<Map<String, dynamic>>
    generateVoices({
  required List<dynamic>
      conversation,
  required List<dynamic>
      characters,
}) async {
  try {
    final response = await http
        .post(
      Uri.parse(
        generateVoicesUrl,
      ),
      headers: {
        "Content-Type":
            "application/json",
      },
      body: jsonEncode({
        "conversation":
            conversation,
        "characters":
            characters,
      }),
    )
        .timeout(
      const Duration(
        minutes: 5,
      ),
    );

    print(
      "GENERATE VOICES CODE: ${response.statusCode}",
    );

    print(
      "GENERATE VOICES BODY:",
    );

    print(response.body);

    if (response.body.isEmpty) {
      throw Exception(
        "Empty voices response",
      );
    }

    return jsonDecode(
      response.body,
    );
  } catch (e) {
    print(
      "GENERATE VOICES ERROR: $e",
    );

    rethrow;
  }
}

/// ===============================
/// 🎞 MERGE MOVIE
/// ===============================
Future<Map<String, dynamic>>
    mergeMovie({
  required List<dynamic> videos,
  required List<dynamic> audios,
}) async {
  try {
    final response = await http
        .post(
      Uri.parse(
        mergeMovieUrl,
      ),
      headers: {
        "Content-Type":
            "application/json",
      },
      body: jsonEncode({
        "videos": videos,
        "audios": audios,
      }),
    )
        .timeout(
      const Duration(
        minutes: 10,
      ),
    );

    print(
      "MERGE MOVIE CODE: ${response.statusCode}",
    );

    print(
      "MERGE MOVIE BODY:",
    );

    print(response.body);

    if (response.body.isEmpty) {
      throw Exception(
        "Empty merge movie response",
      );
    }

    return jsonDecode(
      response.body,
    );
  } catch (e) {
    print(
      "MERGE MOVIE ERROR: $e",
    );

    rethrow;
  }
}