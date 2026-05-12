import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../api.dart';
import '../../video_widget.dart';

class ReplayPage extends StatefulWidget {
  const ReplayPage({super.key});

  @override
  State<ReplayPage> createState() =>
      _ReplayPageState();
}

class CharacterData {
  String name;
  File? image;
  File? voice;

  CharacterData({
    required this.name,
    this.image,
    this.voice,
  });
}

class _ReplayPageState
    extends State<ReplayPage> {
  final List<CharacterData>
      characters = [];

  final TextEditingController
      conversationController =
      TextEditingController();

  bool loading = false;

  String loadingText = "";

  String? finalVideoUrl;

  /// CACHE
  final Map<String, String>
      imageCache = {};

  final Map<String, String>
      audioCache = {};

  @override
  void dispose() {
    conversationController.dispose();
    super.dispose();
  }

  /// =========================
  /// PICK IMAGE
  /// =========================
  Future<File?> pickImage() async {
    final picker = ImagePicker();

    final file = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (file == null) return null;

    return File(file.path);
  }

  /// =========================
  /// PICK AUDIO
  /// =========================
  Future<File?> pickVoice() async {
    final result =
        await FilePicker.platform
            .pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        "mp3",
        "wav",
        "m4a"
      ],
    );

    if (result == null) return null;

    return File(
      result.files.single.path!,
    );
  }

  /// =========================
  /// UPLOAD IMAGE CACHE
  /// =========================
  Future<String?> cachedUploadImage(
    String path,
  ) async {
    if (imageCache.containsKey(path)) {
      return imageCache[path];
    }

    final url =
        await uploadImage(File(path));

    if (url == null) return null;

    imageCache[path] = url;

    return url;
  }

  /// =========================
  /// UPLOAD AUDIO CACHE
  /// =========================
  Future<String?> cachedUploadAudio(
    String path,
  ) async {
    if (audioCache.containsKey(path)) {
      return audioCache[path];
    }

    final url =
        await uploadAudio(File(path));

    if (url == null) return null;

    audioCache[path] = url;

    return url;
  }

  /// =========================
  /// GENERATE MOVIE
  /// =========================
  Future<void>
      generateMovieNow() async {
    try {
      if (characters.isEmpty) {
        throw Exception(
          "Add at least one character",
        );
      }

      if (conversationController.text
          .trim()
          .isEmpty) {
        throw Exception(
          "Conversation is empty",
        );
      }

      setState(() {
        loading = true;
        finalVideoUrl = null;
        loadingText =
            "Uploading characters...";
      });

      /// ======================
      /// 1. UPLOAD CHARACTERS
      /// ======================
      List<Map<String, dynamic>>
          finalCharacters = [];

      for (int i = 0;
          i < characters.length;
          i++) {
        final char = characters[i];

        if (char.image == null) {
          continue;
        }

        final imageUrl =
            await cachedUploadImage(
          char.image!.path,
        );

        String? uploadedVoice;

        if (char.voice != null) {
          uploadedVoice =
              await cachedUploadAudio(
            char.voice!.path,
          );
        }

        finalCharacters.add({
          "name": char.name,
          "image": imageUrl,
          "voice_url":
              uploadedVoice,
        });
      }

      /// ======================
      /// 2. BUILD CONVERSATION
      /// ======================
      setState(() {
        loadingText =
            "Building conversation...";
      });

      final lines =
          conversationController.text
              .split("\n");

      List<Map<String, dynamic>>
          conversation = [];

      for (String line in lines) {
        if (!line.contains(":")) {
          continue;
        }

        final parts =
            line.split(":");

        if (parts.length < 2) {
          continue;
        }

        final character =
            parts[0].trim();

        final text = parts
            .sublist(1)
            .join(":")
            .trim();

        conversation.add({
          "character":
              character,
          "text": text,
        });
      }

      /// ======================
      /// VALIDATE CHARACTERS
      /// ======================
      final characterNames =
          characters
              .map(
                (e) =>
                    e.name.trim(),
              )
              .toList();

      for (var msg
          in conversation) {
        if (!characterNames.contains(
          msg["character"],
        )) {
          throw Exception(
            "Character '${msg["character"]}' not found",
          );
        }
      }

      /// ======================
      /// 3. GENERATE VIDEO
      /// ======================
      setState(() {
        loadingText =
            "Generating cinematic scenes...";
      });

      final taskResult =
          await generateVideoTasks(
        conversation:
            conversation,
        characters:
            finalCharacters,
      );

      List<dynamic> tasks =
          taskResult["tasks"];

      /// ======================
      /// 4. POLLING STATUS
      /// ======================
      setState(() {
        loadingText =
            "Rendering AI videos...";
      });

      List<dynamic> videos = [];

      bool completed = false;

      while (!completed) {
        await Future.delayed(
          const Duration(
            seconds: 15,
          ),
        );

        final statusResult =
            await checkStatus(
          tasks: tasks,
        );

        videos =
            statusResult["videos"];

        /// لو فيه فيديو فشل
        bool hasFailed =
            videos.any(
          (v) =>
              v["status"] ==
              "FAILED",
        );

        if (hasFailed) {
          throw Exception(
            "One or more videos failed",
          );
        }

        /// هل كل الفيديوهات خلصت
        completed = videos.every(
          (v) =>
              v["status"] ==
              "SUCCEEDED",
        );
      }

      /// ======================
      /// 5. GENERATE VOICES
      /// ======================
      setState(() {
        loadingText =
            "Generating AI voices...";
      });

      final voiceResult =
          await generateVoices(
        conversation:
            conversation,
        characters:
            finalCharacters,
      );

      final audios =
          voiceResult["audios"];

      /// ======================
      /// 6. MERGE MOVIE
      /// ======================
      setState(() {
        loadingText =
            "Creating final movie...";
      });

      final mergeResult =
          await mergeMovie(
        videos: videos,
        audios: audios,
      );

      /// ======================
      /// 7. FINAL VIDEO
      /// ======================
      setState(() {
        finalVideoUrl =
            mergeResult[
                "final_video"];

        loading = false;

        loadingText = "";
      });
    } catch (e) {
      setState(() {
        loading = false;
        loadingText = "";
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );
    }
  }

  /// =========================
  /// ADD CHARACTER DIALOG
  /// =========================
  Future<void>
      showAddCharacterDialog() async {
    final nameController =
        TextEditingController();

    File? selectedImage;

    File? selectedVoice;

    await showDialog(
      context: context,
      builder:
          (context) =>
              StatefulBuilder(
        builder: (
          context,
          setDialogState,
        ) {
          return AlertDialog(
            title: const Text(
              "Add Character",
            ),
            content: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                TextField(
                  controller:
                      nameController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        "Character Name",
                  ),
                ),

                const SizedBox(
                    height: 10),

                ElevatedButton(
                  onPressed:
                      () async {
                    final img =
                        await pickImage();

                    if (img != null) {
                      setDialogState(
                          () {
                        selectedImage =
                            img;
                      });
                    }
                  },
                  child: const Text(
                    "Pick Image",
                  ),
                ),

                ElevatedButton(
                  onPressed:
                      () async {
                    final voice =
                        await pickVoice();

                    if (voice != null) {
                      setDialogState(
                          () {
                        selectedVoice =
                            voice;
                      });
                    }
                  },
                  child: const Text(
                    "Pick Voice",
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (nameController.text
                      .trim()
                      .isEmpty) {
                    return;
                  }

                  characters.add(
                    CharacterData(
                      name:
                          nameController
                              .text
                              .trim(),
                      image:
                          selectedImage,
                      voice:
                          selectedVoice,
                    ),
                  );

                  setState(() {});

                  Navigator.pop(
                    context,
                  );
                },
                child:
                    const Text(
                  "Add",
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// =========================
  /// CHARACTER CARD
  /// =========================
  Widget characterCard(
    CharacterData char,
    int index,
  ) {
    return Card(
      child: ListTile(
        title: Text(char.name),
        subtitle: Text(
          "${char.image != null ? "Image ✔" : "No Image"} | "
          "${char.voice != null ? "Voice ✔" : "Default AI Voice"}",
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete,
          ),
          onPressed: () {
            setState(() {
              characters.removeAt(
                index,
              );
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI Movie Generator",
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// CONVERSATION
            TextField(
              controller:
                  conversationController,
              maxLines: 8,
              decoration:
                  const InputDecoration(
                hintText:
                    "Ahmed: Hello\nSara: Hi",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
                height: 20),

            /// ADD CHARACTER
            ElevatedButton(
              onPressed:
                  showAddCharacterDialog,
              child: const Text(
                "Add Character",
              ),
            ),

            const SizedBox(
                height: 20),

            /// CHARACTER LIST
            ...characters
                .asMap()
                .entries
                .map(
                  (e) =>
                      characterCard(
                    e.value,
                    e.key,
                  ),
                ),

            const SizedBox(
                height: 20),

            /// GENERATE BUTTON
            ElevatedButton(
              onPressed: loading
                  ? null
                  : generateMovieNow,
              child: Text(
                loading
                    ? loadingText
                    : "Generate AI Movie",
              ),
            ),

            const SizedBox(
                height: 20),

            /// LOADING
            if (loading)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(
                      height: 15),
                  Text(
                    loadingText,
                  ),
                ],
              ),

            const SizedBox(
                height: 20),

            /// FINAL VIDEO
            if (finalVideoUrl != null)
              VideoWidget(
                videoUrl:
                    finalVideoUrl!,
              ),
          ],
        ),
      ),
    );
  }
}