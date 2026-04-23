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
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
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

  Future<void> showAddCharacterDialog() async {
    final TextEditingController nameController = TextEditingController();
    File? selectedImage;
    File? selectedVoice;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add Character"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: "Character Name"),
                ),
                const SizedBox(height: 12),

                ElevatedButton.icon(
                  onPressed: () async {
                    File? img = await pickImage();
                    if (img != null) {
                      setDialogState(() {
                        selectedImage = img;
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: Text(
                    selectedImage == null
                        ? "Pick Image"
                        : "Image Selected",
                  ),
                ),
                const SizedBox(height: 8),

                ElevatedButton.icon(
                  onPressed: () async {
                    File? voice = await pickVoice();
                    if (voice != null) {
                      setDialogState(() {
                        selectedVoice = voice;
                      });
                    }
                  },
                  icon: const Icon(Icons.music_note),
                  label: Text(
                    selectedVoice == null
                        ? "Pick Voice"
                        : "Voice Selected",
                  ),
                ),
              ],
            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(char.name,
                    style: const TextStyle(fontSize: 16)),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => characters.removeAt(index)),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: char.image == null
                      ? const Center(child: Text("No Image"))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(char.image!,
                              fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: char.voice == null
                      ? const Center(child: Text("No Voice"))
                      : const Center(
                          child: Icon(Icons.check_circle,
                              color: Colors.green, size: 40),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Text to Video"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Script / Dialogue",
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              maxLines: 6,
              controller: scriptController,
              decoration: InputDecoration(
                hintText:
                    "Your character will speak this text...",
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text("Characters",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: showAddCharacterDialog,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Character"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        setState(() => loading = true);

                        /// 1️⃣ رفع الشخصيات
                        List<Map<String, dynamic>> finalCharacters = [];

                        for (var char in characters) {
                          String? imageUrl;
                          String? audioUrl;

                          try {
                            if (char.image != null) {
                              imageUrl =
                                  await uploadToCloudinary(char.image!);
                            }
                          } catch (e) {
                            print("Upload image error: $e");
                          }

                          try {
                            if (char.voice != null) {
                              audioUrl =
                                  await uploadAudio(char.voice!);
                            }
                          } catch (e) {
                            print("Upload audio error: $e");
                          }

                          finalCharacters.add({
                            "name": char.name,
                            "image": imageUrl,
                            "audio": audioUrl,
                          });
                        }

                        /// 2️⃣ تجهيز ورفع dialogues
                        final scenes =
                            buildCharacterScenes(scriptController.text);

                        for (var d in scenes) {
                          try {
                            if (d["image"] != null) {
                              d["image"] =
                                  await uploadToCloudinary(File(d["image"]));
                            }
                          } catch (e) {
                            print("Dialogue image error: $e");
                          }

                          try {
                            if (d["audio"] != null) {
                              d["audio"] =
                                  await uploadAudio(File(d["audio"]));
                            }
                          } catch (e) {
                            print("Dialogue audio error: $e");
                          }
                        }

                        /// 3️⃣ إرسال
                        final data = await generateVideoWithUrls(
                          prompt: scriptController.text.isEmpty
                              ? "ولد حزين ثم يبتسم"
                              : scriptController.text,
                          characters: finalCharacters,
                          dialogues: scenes,
                        );

                        /// 4️⃣ polling
                        if (data["status"] == "processing") {
                          final id = data["prediction_id"];

                          final url = await waitForVideo(id);

                          setState(() {
                            videoUrl = url;
                            loading = false;
                          });
                        } else {
                          print("Error from n8n");
                          setState(() => loading = false);
                        }
                      },
                child: Text(
                    loading ? "Processing..." : "Generate Video"),
              ),
            ),

            const SizedBox(height: 20),

            if (videoUrl != null)
              SizedBox(
                  height: 250,
                  child: VideoWidget(videoUrl: videoUrl!)),
          ],
        ),
      ),
    );
  }
}