import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// ===================================
/// 🌐 N8N WEBHOOK
/// ===================================

const String webhookUrl =
    "https://n8n-production-9d7d.up.railway.app/webhook/generate-veo-video";

/// ===================================
/// ☁️ CLOUDINARY
/// ===================================

const String cloudName =
    "dfyyydlmk";

const String uploadPreset =
    "life_twin";

/// ===================================
/// 🌐 API SERVICE
/// ===================================

class ApiService {

  /// ===================================
  /// 🌍 DETECT LANGUAGE
  /// ===================================

  static String detectLanguage(
    String text,
  ) {

    final arabicRegex =
        RegExp(r'[\u0600-\u06FF]');

    return arabicRegex.hasMatch(text)

        ? "Arabic"

        : "English";
  }

  /// ===================================
  /// 🌐 COMMON POST
  /// ===================================

  static Future<Map<String, dynamic>?>
  postJson({

    required String url,

    required Map<String, dynamic>
    body,

    int timeoutMinutes = 30,

    int retries = 1,

  }) async {

    for (int attempt = 0;
        attempt < retries;
        attempt++) {

      try {

        debugPrint(
          "=================================",
        );

        debugPrint(
          "POST ATTEMPT => ${attempt + 1}",
        );

        debugPrint(
          "URL => $url",
        );

        debugPrint(
          "REQUEST BODY => ${jsonEncode(body)}",
        );

        final response =
            await http
                .post(

                  Uri.parse(url),

                  headers: {

                    "Content-Type":
                        "application/json",

                    "Accept":
                        "application/json",
                  },

                  body:
                      jsonEncode(body),

                )
                .timeout(

                  Duration(
                    minutes:
                        timeoutMinutes,
                  ),
                );

        debugPrint(
          "STATUS => ${response.statusCode}",
        );

        debugPrint(
          "RESPONSE => ${response.body}",
        );

        debugPrint(
          "=================================",
        );

        if (response.body.isEmpty) {

          throw Exception(
            "Empty response body",
          );
        }

        final data =
            jsonDecode(response.body);

        if (response.statusCode ==
            200) {

          return data;
        }

        throw Exception(
          "HTTP ${response.statusCode}",
        );

      } catch (e) {

        debugPrint(
          "POST ERROR => $e",
        );

        if (attempt ==
            retries - 1) {

          return null;
        }

        await Future.delayed(
          const Duration(
            seconds: 2,
          ),
        );
      }
    }

    return null;
  }

  /// ===================================
  /// ☁️ COMMON CLOUDINARY UPLOAD
  /// ===================================

  static Future<String?> uploadFile({

    required File file,

    required String resourceType,

  }) async {

    try {

      debugPrint(
        "=================================",
      );

      debugPrint(
        "UPLOADING FILE => ${file.path}",
      );

      final request =
          http.MultipartRequest(

            'POST',

            Uri.parse(

              "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload",

            ),
          );

      request.fields['upload_preset'] =
          uploadPreset;

      request.files.add(

        await http.MultipartFile
            .fromPath(

              'file',

              file.path,
            ),
      );

      final response =
          await request.send();

      final body =
          await response.stream
              .bytesToString();

      debugPrint(
        "UPLOAD RESPONSE => $body",
      );

      final data =
          jsonDecode(body);

      if (response.statusCode ==
              200 ||
          response.statusCode ==
              201) {

        return data["secure_url"];
      }

      throw Exception(
        "Upload failed",
      );

    } catch (e) {

      debugPrint(
        "UPLOAD ERROR => $e",
      );

      return null;
    }
  }

  /// ===================================
  /// ☁️ IMAGE UPLOAD
  /// ===================================

  static Future<String?>
  uploadImage(
    File file,
  ) async {

    return await uploadFile(

      file: file,

      resourceType:
          "image",
    );
  }

  /// ===================================
  /// ☁️ AUDIO UPLOAD
  /// ===================================

  static Future<String?>
  uploadAudio(
    File file,
  ) async {

    return await uploadFile(

      file: file,

      resourceType:
          "video",
    );
  }

  /// ===================================
  /// 🎬 GENERATE SCENE
  /// ===================================

  static Future<Map<String, dynamic>?>
  generateScene({

    required String prompt,

    required String background,

    required String style,

    required String language,

    required List<Map<String, dynamic>>
        characters,

  }) async {

    /// ===============================
    /// 🌍 DETECT LANGUAGE
    /// ===============================

    final detectedLanguage =
        detectLanguage(prompt);

    /// ===============================
    /// 📦 REQUEST BODY
    /// ===============================

    final body = {

      "prompt":
          prompt.trim(),

      "background":
          background.trim(),

      "style":
          style.trim(),

      "language":
          detectedLanguage,

      "characters":
          characters,
    };

    debugPrint(
      "FINAL GENERATE BODY => ${jsonEncode(body)}",
    );

    /// ===============================
    /// 🚀 SEND REQUEST
    /// ===============================

    final result =
        await postJson(

      url: webhookUrl,

      body: body,

      timeoutMinutes: 30,

      retries: 1,
    );

    /// ===============================
    /// ❌ NULL RESULT
    /// ===============================

    if (result == null) {

      debugPrint(
        "NULL RESULT FROM BACKEND",
      );

      return null;
    }

    debugPrint(
      "FINAL RESULT => $result",
    );

    /// ===============================
    /// ⚠️ VIDEO CHECK
    /// ===============================

    if (result["video_url"] ==
            null ||
        result["video_url"]
            .toString()
            .isEmpty) {

      debugPrint(
        "WARNING => VIDEO URL EMPTY",
      );
    }

    return result;
  }
}