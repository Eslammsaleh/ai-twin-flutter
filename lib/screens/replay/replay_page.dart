import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

/// =======================================
/// CHARACTER MODEL
/// =======================================

class CharacterData {
  String name;
  String gender;
  File? image;
  String voiceId; 

  CharacterData({
    required this.name,
    required this.gender,
    this.image,
    required this.voiceId,
  });
}

/// =======================================
/// REPLAY PAGE
/// =======================================

class ReplayPage extends StatefulWidget {
  const ReplayPage({
    super.key,
  });

  @override
  State<ReplayPage> createState() => _ReplayPageState();
}

class _ReplayPageState extends State<ReplayPage> {
  /// =====================================
  /// CHARACTERS
  /// =====================================

  final List<CharacterData> characters = [];

  /// =====================================
  /// CONTROLLERS
  /// =====================================

  final TextEditingController scenePromptController = TextEditingController(
    text: "Two males walking on Cairo Nile Corniche at night,cinematic lighting, film look",
  );

  final TextEditingController dialogueController = TextEditingController(
    text: "eslam: انت اخويا يا بيتر\npeter: حبيبي يا اسلام وانت كمان",
  );

  /// =====================================
  /// STATES
  /// =====================================

  bool loading = false;
  String loadingText = "";
  String? finalVideoPath;
  VideoPlayerController? videoController;

  /// =====================================
  /// FIXED VOICE MAPS FROM DOCUMENTATION
  /// =====================================

  final List<Map<String, String>> maleVoices = [
    {"name": "Adam", "id": "pNInz6obpgDQGcFmaJgB"},
    {"name": "Arnold", "id": "ErXwobaYiN019PkySvjV"},
  ];

  final List<Map<String, String>> femaleVoices = [
    {"name": "Rachel", "id": "21m00Tcm4TlvDq8ikWAM"},
    {"name": "Bella", "id": "EXAVITQu4vr4xnSDxMaL"},
  ];

  /// =====================================
  /// DISPOSE
  /// =====================================

  @override
  void dispose() {
    scenePromptController.dispose();
    dialogueController.dispose();
    videoController?.dispose();
    super.dispose();
  }

  /// =====================================
  /// UPDATE LOADING
  /// =====================================

  void updateLoading(String text) {
    if (!mounted) return;
    setState(() {
      loadingText = text;
    });
  }

  /// =====================================
  /// PICK IMAGE
  /// =====================================

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return null;
    return File(file.path);
  }

  /// =====================================
  /// INIT VIDEO
  /// =====================================

  Future<void> initVideo(String url) async {
    try {
      videoController?.dispose();
      videoController = VideoPlayerController.networkUrl(
        Uri.parse(url),
      );

      await videoController!.initialize();
      await videoController!.setLooping(true);
      await videoController!.setVolume(1);
      await videoController!.play();

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint("VIDEO INIT ERROR => $e");
    }
  }

  /// =====================================
  /// GENERATE MOVIE
  /// =====================================

  Future<void> generateMovieNow() async {
    if (loading) return;

    try {
      /// =========================
      /// VALIDATION
      /// =========================

      if (characters.isEmpty) {
        throw Exception("Add at least one character");
      }

      for (var char in characters) {
        if (char.image == null) {
          throw Exception("Please select an image for ${char.name}");
        }
      }

      if (scenePromptController.text.trim().isEmpty) {
        throw Exception("Scene prompt is empty");
      }

      if (dialogueController.text.trim().isEmpty) {
        throw Exception("Dialogue script is empty");
      }

      /// =========================
      /// START LOADING
      /// =========================

      setState(() {
        loading = true;
        finalVideoPath = null;
      });

      updateLoading("Preparing inputs and extracting frames...");

      /// ========================================
      /// EXTRACT LIST OF IMAGES & CHARACTER MAPS
      /// ========================================

      List<File> imageFiles = [];
      List<Map<String, dynamic>> finalCharactersList = [];

      for (var char in characters) {
        imageFiles.add(char.image!);
        
        finalCharactersList.add({
          "name": char.name.trim().toLowerCase(),
          "gender": char.gender,
          "voice_id": char.voiceId,
        });
      }

      updateLoading("AI Pipeline is generating your movie...\nThis may take around 2 minutes.");

      /// =========================
      /// SEND TO BACKEND V2
      /// =========================

      final result = await ApiService.generateVideo(
        images: imageFiles,
        characters: finalCharactersList,
        prompt: scenePromptController.text.trim(),
        dialogue: dialogueController.text.trim(),
      );

      /// =========================
      /// PROCESSING RESULT
      /// =========================

      if (result == null || result["success"] != true) {
        String errMsg = result != null ? result["error"] ?? "Unknown server error" : "No response from server";
        throw Exception(errMsg);
      }

      final String? videoUrl = result["video_url"];
      if (videoUrl == null || videoUrl.isEmpty) {
        throw Exception("Rendered video URL missing from response.");
      }

      updateLoading("Preparing cinematic replay...");
      await initVideo(videoUrl);

      if (!mounted) return;
      setState(() {
        finalVideoPath = result["video_path"];
        loading = false;
        loadingText = "";
      });

    } catch (e) {
      debugPrint("GENERATE ERROR => $e");
      if (!mounted) return;
      setState(() {
        loading = false;
        loadingText = "";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("ERROR: ${e.toString().replaceAll("Exception:", "")}"),
        ),
      );
    }
  }

  /// =====================================
  /// ADD CHARACTER DIALOG
  /// =====================================

  Future<void> showAddCharacterDialog() async {
    final nameController = TextEditingController();
    String gender = "male";
    String selectedVoiceId = maleVoices.first["id"]!;
    File? selectedImage;

    // جلب نمط الثيم الحالي داخل الـ Dialog ليتناسق معه
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          var currentVoices = gender == "male" ? maleVoices : femaleVoices;

          return AlertDialog(
            backgroundColor: theme.cardColor,
            title: const Text("Add Character", style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Character Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: "male", child: Text("Male")),
                      DropdownMenuItem(value: "female", child: Text("Female")),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        gender = value!;
                        selectedVoiceId = gender == "male" ? maleVoices.first["id"]! : femaleVoices.first["id"]!;
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedVoiceId,
                    decoration: const InputDecoration(labelText: "Voice Actor", border: OutlineInputBorder()),
                    items: currentVoices.map((v) {
                      return DropdownMenuItem(value: v["id"]!, child: Text(v["name"]!));
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedVoiceId = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      foregroundColor: theme.colorScheme.primary,
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final img = await pickImage();
                      if (img != null) {
                        setDialogState(() {
                          selectedImage = img;
                        });
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: Text(
                      selectedImage != null ? "Image Selected ✔" : "Pick Character Face",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: theme.colorScheme.primary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (nameController.text.trim().length < 2) return;
                  if (selectedImage == null) return;

                  characters.add(
                    CharacterData(
                      name: nameController.text.trim(),
                      gender: gender,
                      image: selectedImage,
                      voiceId: selectedVoiceId,
                    ),
                  );

                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }

  /// =====================================
  /// CHARACTER CARD
  /// =====================================

  Widget characterCard(CharacterData char, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      child: ListTile(
        leading: char.image != null
            ? CircleAvatar(
                backgroundImage: FileImage(char.image!),
              )
            : const CircleAvatar(
                child: Icon(Icons.person),
              ),
        title: Text(char.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Gender: ${char.gender.toUpperCase()}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            setState(() {
              characters.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  /// =====================================
  /// BUILD MAIN UI
  /// =====================================

  @override
  Widget build(BuildContext context) {
    // جلب بيانات الثيم الحالي من الـ Context ديناميكياً
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Cinematic Engine v2", style: TextStyle(fontWeight: FontWeight.bold)),
        // يعتمد الآن تلقائياً على الـ AppBar Theme الممرر من الـ Settings
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation ?? 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddCharacterDialog,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text(
                  "Scene Settings",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: scenePromptController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: "Scene Prompt (Background & Styling)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: dialogueController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: "Dialogue Script (format -> name: script)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Cast Characters",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Total: ${characters.length}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (characters.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        "No characters added yet. Tap the '+' button below.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ...characters.asMap().entries.map(
                      (e) => characterCard(e.value, e.key),
                    ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary, // بنفسجي في الـ Light/Dark حسب الثيم الخاص بك
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: loading ? null : generateMovieNow,
                    child: const Text(
                      "Generate AI Movie",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (videoController != null && videoController!.value.isInitialized) ...[
                  const Text(
                    "🎬 Preview Generated Cinema",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  AspectRatio(
                    aspectRatio: videoController!.value.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: VideoPlayer(videoController!),
                    ),
                  ),
                  if (finalVideoPath != null) ...[
                    const SizedBox(height: 10),
                    SelectableText(
                      "Saved at: $finalVideoPath",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ]
                ],
              ],
            ),
          ),
          
          // شاشة التحميل المتجاوبة بالكامل مع الـ Dark & Light Mode
          if (loading)
            Container(
              color: isDark ? Colors.black.withOpacity(0.85) : Colors.white.withOpacity(0.9),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        loadingText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}