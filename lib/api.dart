import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// ===================================
/// 🌐 N8N WEBHOOK
/// ===================================

const String webhookUrl =
    "https://n8n-culu.onrender.com/webhook/generate-veo-video";

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
  /// 🌐 COMMON POST
  /// ===================================

  static Future<Map<String, dynamic>?>
  postJson({

    required String url,

    required Map<String, dynamic>
    body,

    int timeoutMinutes = 30,

    int retries = 3,

  }) async {

    for (int attempt = 0;
        attempt < retries;
        attempt++) {

      try {

        print(
          "=================================",
        );

        print(
          "POST ATTEMPT => ${attempt + 1}",
        );

        print("URL => $url");

        print(
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

        print(
          "STATUS => ${response.statusCode}",
        );

        print(
          "RESPONSE => ${response.body}",
        );

        print(
          "=================================",
        );

        /// EMPTY

        if (response.body.isEmpty) {

          throw Exception(
            "Empty response body",
          );
        }

        /// DECODE

        final data =
            jsonDecode(response.body);

        /// SUCCESS

        if (response.statusCode ==
            200) {

          return data;
        }

        /// ERROR

        throw Exception(
          "HTTP ${response.statusCode}",
        );

      } catch (e) {

        print(
          "POST ERROR => $e",
        );

        /// LAST RETRY

        if (attempt ==
            retries - 1) {

          return null;
        }

        /// WAIT BEFORE RETRY

        await Future.delayed(
          Duration(
            seconds:
                2 + attempt,
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

      print(
        "=================================",
      );

      print(
        "UPLOADING FILE => ${file.path}",
      );

      final request =
          http.MultipartRequest(

            'POST',

            Uri.parse(

              "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload",

            ),
          );

      /// PRESET

      request.fields['upload_preset'] =
          uploadPreset;

      /// FILE

      request.files.add(

        await http.MultipartFile
            .fromPath(

              'file',

              file.path,

            ),
      );

      /// SEND

      final response =
          await request.send();

      /// BODY

      final body =
          await response.stream
              .bytesToString();

      print(
        "UPLOAD RESPONSE => $body",
      );

      final data =
          jsonDecode(body);

      /// SUCCESS

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

      print(
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

    required List<Map<String, dynamic>>
    characters,

    String language =
        "English",

  }) async {

    final body = {

      "prompt":
          prompt.trim(),

      "background":
          background.trim(),

      "style":
          style.trim(),

      "language":
          language,

      "characters":
          characters,
    };

    print(
      "FINAL GENERATE BODY => ${jsonEncode(body)}",
    );

    final result =
        await postJson(

      url: webhookUrl,

      body: body,

      timeoutMinutes: 30,

      retries: 3,
    );

    /// VALIDATE RESULT

    if (result == null) {

      print(
        "NULL RESULT FROM BACKEND",
      );

      return null;
    }

    /// DEBUG

    print(
      "FINAL RESULT => $result",
    );

    /// CHECK VIDEO

    if (result["video_url"] ==
            null ||
        result["video_url"]
            .toString()
            .isEmpty) {

      print(
        "WARNING => VIDEO URL EMPTY",
      );
    }

    return result;
  }
}