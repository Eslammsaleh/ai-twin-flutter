import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> generateVideo({
  required String prompt,
  List<Map<String, dynamic>>? charactersData,
  List<Map<String, dynamic>>? dialogues, // ✅ تم التعديل
}) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("https://n8n-culu.onrender.com/webhook/generate-video"),
    );

    /// 🧠 النص
    request.fields['prompt'] = prompt;

    /// 👥 الشخصيات (صورة + صوت لكل واحدة)
    if (charactersData != null && charactersData.isNotEmpty) {
      for (int i = 0; i < charactersData.length; i++) {
        final char = charactersData[i];

        /// الاسم
        if (char["name"] != null) {
          request.fields['characters[$i][name]'] = char["name"];
        }

        /// 🖼️ صورة
        if (char["image"] != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'characters[$i][image]',
              char["image"],
            ),
          );
        }

        /// 🔊 صوت
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

    /// 🎬 dialogues مربوط بالشخصيات (🔥 الأهم)
    if (dialogues != null && dialogues.isNotEmpty) {
      for (int i = 0; i < dialogues.length; i++) {
        final d = dialogues[i];

        /// 👤 الاسم
        request.fields['dialogues[$i][name]'] = d["name"] ?? "";

        /// 💬 النص
        request.fields['dialogues[$i][text]'] = d["text"] ?? "";

        /// 🖼️ الصورة (لو موجودة)
        if (d["image"] != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'dialogues[$i][image]',
              d["image"],
            ),
          );
        }

        /// 🔊 الصوت (لو موجود)
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

    /// 🚀 إرسال الطلب
    var response = await request.send();

    /// 📥 قراءة الرد
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