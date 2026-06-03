import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // ستحتاجها لتحديد نوع الصورة (jpeg/png) لضمان استقبالها في FastAPI بدون مشاكل

class ApiService {
  // رابط السيرفر المرفوع على ريندر كما هو في الـ Production
  static const String baseUrl = "https://ai-cinematic-backend.onrender.com";

  /// دالة كشف اللغة المستخدمة في حقل الـ Dialogue
  static String detectLanguage(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text) ? "Arabic" : "English";
  }

  /// دالة توليد الفيديو V2 بالاتصال بـ FastAPI Pipeline
  static Future<Map<String, dynamic>?> generateVideo({
    required List<File> images,
    required List<Map<String, dynamic>> characters,
    required String prompt,
    required String dialogue,
  }) async {
    try {
      // إعداد الـ Request ونوع الـ Method والـ Endpoint الصحيحة
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/generate-video-v2"),
      );

      // 1. إضافة الحقول النصية الأساسية (Prompt & Dialogue)
      request.fields["prompt"] = prompt;
      request.fields["dialogue"] = dialogue;

      // 2. تحويل مصفوفة الـ Characters إلى JSON String وإضافتها كحقل نصي متوافق مع json.loads() بالباك-إند
      request.fields["characters"] = jsonEncode(characters);

      // 3. إضافة ملفات الصور المرفوعة بترتيب مصفوفة الشخصيات
      for (final image in images) {
        // نحدد نوع الملف للتأكد من أن السيرفر سيتعرف عليه كـ Image/jpeg أو Image/png
        final String extension = image.path.split('.').last.toLowerCase();
        final String contentType = extension == 'png' ? 'png' : 'jpeg';

        final multipartFile = await http.MultipartFile.fromPath(
          "images", // يجب أن يطابق اسم البارامتر المتوقع في البايثون List[UploadFile] = File(...)
          image.path,
          contentType: MediaType('image', contentType),
        );
        
        request.files.add(multipartFile);
      }

      debugPrint("API LOG => Sending request to V2 Pipeline with ${images.length} images...");
      debugPrint("API LOG => prompt: ${request.fields['prompt']}");
      debugPrint("API LOG => dialogue: ${request.fields['dialogue']}");
      debugPrint("API LOG => characters: ${request.fields['characters']}");
      debugPrint("API LOG => images: ${request.files.map((f) => f.filename).toList()}");

      // 4. إرسال الطلب إلى السيرفر
      final response = await request.send();

      // 5. تحويل الـ Stream المستلم إلى نص String عادي لقراءته
      final body = await response.stream.bytesToString();

      debugPrint("RESPONSE FROM SERVER => $body");

      // 6. فك تشفير النص الراجع إلى Map وإرجاعه للواجهة (Replay Page)
      return jsonDecode(body);

    } catch (e) {
      debugPrint("API CRITICAL ERROR => $e");

      // إرجاع خريطة تحتوي على الفشل لكي لا ينهار التطبيق في الواجهة ويعرض رسالة خطأ للمستخدم
      return {
        "success": false,
        "error": e.toString(),
      };
    }
  }
}