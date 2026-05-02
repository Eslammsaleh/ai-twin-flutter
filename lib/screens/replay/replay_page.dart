import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../theme/app_colors.dart';
import '../../api.dart';
import '../../video_widget.dart';

class ReplayPage extends StatefulWidget {
  const ReplayPage({super.key});

  @override
  State<ReplayPage> createState() => _ReplayPageState();
}

class CharacterData {
  String name;
  File? image;
  File? voice;

  CharacterData({this.name = "Character", this.image, this.voice});
}

class _ReplayPageState extends State<ReplayPage> {
  final List<CharacterData> characters = [];
  final TextEditingController scriptController = TextEditingController();

  String? videoUrl;
  bool loading = false;
  bool isCancelled = false;

  final Map<String, String> imageCache = {};
  final Map<String, String> audioCache = {};

  @override
  void dispose() {
    isCancelled = true;
    scriptController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> buildCharacterScenes(String text) {
    final lines = text.split('\n');
    List<Map<String, dynamic>> scenes = [];

    for (var line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        final name = parts[0].trim();
        final speech = parts.sublist(1).join(':').trim();

        final char = characters.firstWhere(
          (c) => c.name == name,
          orElse: () => CharacterData(name: name),
        );

        scenes.add({
          "name": name,
          "text": speech,
          "image": char.image?.path,
          "audio": char.voice?.path,
        });
      }
    }

    return scenes;
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) return File(file.path);
    return null;
  }

  Future<File?> pickVoice() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["mp3", "wav", "ogg"],
    );

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    }

    return null;
  }

  Future<String?> cachedUploadImage(String path) async {
    if (imageCache.containsKey(path)) return imageCache[path];

    final url = await uploadToCloudinary(File(path));

    if (url == null || url.toString().isEmpty) {
      throw Exception("Image upload failed");
    }

    imageCache[path] = url;
    return url;
  }

  Future<String?> cachedUploadAudio(String path) async {
    if (audioCache.containsKey(path)) return audioCache[path];

    final url = await uploadAudio(File(path));

    if (url == null || url.toString().isEmpty) {
      throw Exception("Audio upload failed");
    }

    audioCache[path] = url;
    return url;
  }

  Future<String?> safeWaitForVideo(String id) async {
    if (isCancelled) return null;

    final url = await waitForVideo(id);

    if (isCancelled) return null;

    if (url == null || url.toString().isEmpty) {
      throw Exception("Video URL is empty");
    }

    return url;
  }

  Future<void> showAddCharacterDialog() async {
    final nameController = TextEditingController();

    File? selectedImage;
    File? selectedVoice;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add Character"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: "Character Name"),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: () async {
                  final img = await pickImage();

                  if (img != null) {
                    setDialogState(() => selectedImage = img);
                  }
                },
                child: Text(
                  selectedImage == null
                      ? "Pick Image"
                      : "Image Selected",
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () async {
                  final voice = await pickVoice();

                  if (voice != null) {
                    setDialogState(() => selectedVoice = voice);
                  }
                },
                child: Text(
                  selectedVoice == null
                      ? "Pick Voice"
                      : "Voice Selected",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  setState(() {
                    characters.add(
                      CharacterData(
                        name: nameController.text.trim(),
                        image: selectedImage,
                        voice: selectedVoice,
                      ),
                    );
                  });

                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  Widget characterCard(CharacterData char, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(char.name)),
              IconButton(
                onPressed: () =>
                    setState(() => characters.removeAt(index)),
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: char.image == null
                    ? const Text("No Image")
                    : Image.file(char.image!, height: 100),
              ),
              Expanded(
                child: char.voice == null
                    ? const Text("No Voice")
                    : const Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> generateVideoNow() async {
    try {
      setState(() {
        loading = true;
        videoUrl = null;
      });

      final futures = characters.map((char) async {
        final charData = {
          "name": char.name,
        };

        final img = char.image != null
            ? await cachedUploadImage(char.image!.path)
            : null;

        if (img != null) {
          charData["image"] = img;
        }

        final audio = char.voice != null
            ? await cachedUploadAudio(char.voice!.path)
            : null;

        if (audio != null) {
          charData["audio"] = audio;
        }

        return charData;
      }).toList();

      final finalCharacters = await Future.wait(futures);

      print("FINAL CHARACTERS:");
      print(finalCharacters);

      final scenes = buildCharacterScenes(scriptController.text);

      final data = await generateVideoWithUrls(
        prompt: scriptController.text,
        characters: finalCharacters,
        dialogues: scenes,
      );

      if (data["status"] == "processing") {
        final id = data["id"];

        final url = await safeWaitForVideo(id);

        if (!mounted) return;

        setState(() {
          videoUrl = url;
          loading = false;
        });
      } else {
        if (!mounted) return;

        setState(() => loading = false);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Text to Video"),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const Text("Script"),

                TextField(
                  controller: scriptController,
                  maxLines: 5,
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Characters"),
                    ElevatedButton(
                      onPressed: showAddCharacterDialog,
                      child: const Text("Add Character"),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                ...characters.asMap().entries.map(
                      (e) => characterCard(
                        e.value,
                        e.key,
                      ),
                    ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loading ? null : generateVideoNow,
                  child: Text(
                    loading
                        ? "Processing..."
                        : "Generate Video",
                  ),
                ),

                if (videoUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: VideoWidget(videoUrl: videoUrl!),
                  ),
              ],
            ),
          ),

          if (loading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}