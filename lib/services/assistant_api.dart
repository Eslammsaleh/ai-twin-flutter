import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class AssistantAPI {

  static const String baseUrl =
      "https://cinematic-assistant-api.onrender.com";

  // =========================
  // START ASSISTANT
  // =========================

  static Future<Map<String, dynamic>>
  startAssistant() async {

    try {

      final response = await http
          .get(
            Uri.parse(
              "$baseUrl/assistant/start",
            ),
          )
          .timeout(
            const Duration(seconds: 30),
          );

      return _handleResponse(response);

    } catch (e) {

      return _errorResponse(e);
    }
  }

  // =========================
  // SEND CHOICE
  // =========================

  static Future<Map<String, dynamic>>
  sendChoice(String choice) async {

    try {

      final response = await http
          .post(

            Uri.parse(
              "$baseUrl/assistant/reply",
            ),

            headers: {
              "Content-Type":
                  "application/json",
            },

            body: jsonEncode({
              "choice": choice,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
          );

      return _handleResponse(response);

    } catch (e) {

      return _errorResponse(e);
    }
  }

  // =========================
  // SEND MESSAGE
  // =========================

  static Future<Map<String, dynamic>>
  sendMessage(String message)
  async {

    try {

      final response = await http
          .post(

            Uri.parse(
              "$baseUrl/assistant/message",
            ),

            headers: {
              "Content-Type":
                  "application/json",
            },

            body: jsonEncode({
              "message": message,
            }),
          )
          .timeout(
            const Duration(seconds: 60),
          );

      return _handleResponse(response);

    } catch (e) {

      return _errorResponse(e);
    }
  }

  // =========================
  // HANDLE RESPONSE
  // =========================

  static Map<String, dynamic>
  _handleResponse(
    http.Response response,
  ) {

    try {

      final data =
          jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {

        return {

          "type":
              data["type"] ??
              "message",

          "message":
              data["message"] ??
              "تم بنجاح",

          "options":
              List<dynamic>.from(
            data["options"] ?? [],
          ),

          "tips":
              List<dynamic>.from(
            data["tips"] ?? [],
          ),
        };
      }

      return {

        "type": "error",

        "message":
            data["message"] ??
            "Server Error",

        "options": [],

        "tips": [],
      };

    } catch (e) {

      return {

        "type": "error",

        "message":
            "Invalid server response",

        "options": [],

        "tips": [],
      };
    }
  }

  // =========================
  // ERROR RESPONSE
  // =========================

  static Map<String, dynamic>
  _errorResponse(dynamic e) {

    return {

      "type": "error",

      "message":
          e.toString(),

      "options": [],

      "tips": [],
    };
  }
}