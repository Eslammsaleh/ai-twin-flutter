import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../api.dart';

/// =======================================
/// CHARACTER MODEL
/// =======================================

class CharacterData {

  String name;

  String gender;

  String appearance;

  File? image;

  File? voice;

  CharacterData({

    required this.name,

    required this.gender,

    required this.appearance,

    this.image,

    this.voice,
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
  State<ReplayPage> createState() =>
      _ReplayPageState();
}

class _ReplayPageState
    extends State<ReplayPage> {

  /// =====================================
  /// CHARACTERS
  /// =====================================

  final List<CharacterData>
      characters = [];

  /// =====================================
  /// CONTROLLERS
  /// =====================================

  final TextEditingController
      scenePromptController =
      TextEditingController();

  final TextEditingController
      backgroundController =
      TextEditingController(
    text:
        "Modern cinematic background",
  );

  /// =====================================
  /// STATES
  /// =====================================

  bool loading = false;

  String loadingText = "";

  String? finalDialogue;

  VideoPlayerController?
  videoController;

  /// =====================================
  /// CACHE
  /// =====================================

  final Map<String, String>
      imageCache = {};

  final Map<String, String>
      audioCache = {};

  /// =====================================
  /// DISPOSE
  /// =====================================

  @override
  void dispose() {

    scenePromptController.dispose();

    backgroundController.dispose();

    videoController?.dispose();

    super.dispose();
  }

  /// =====================================
  /// UPDATE LOADING
  /// =====================================

  void updateLoading(
    String text,
  ) {

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

    final file =
        await picker.pickImage(

      source:
          ImageSource.gallery,

      imageQuality: 90,
    );

    if (file == null) {
      return null;
    }

    return File(file.path);
  }

  /// =====================================
  /// PICK AUDIO
  /// =====================================

  Future<File?> pickAudio() async {

    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result == null) {
      return null;
    }

    return File(
      result.files.single.path!,
    );
  }

  /// =====================================
  /// IMAGE CACHE
  /// =====================================

  Future<String?> cachedUploadImage(
    String path,
  ) async {

    if (imageCache.containsKey(path)) {

      return imageCache[path];
    }

    final url =
        await ApiService.uploadImage(
      File(path),
    );

    if (url == null) {
      return null;
    }

    imageCache[path] = url;

    return url;
  }

  /// =====================================
  /// AUDIO CACHE
  /// =====================================

  Future<String?> cachedUploadAudio(
    String path,
  ) async {

    if (audioCache.containsKey(path)) {

      return audioCache[path];
    }

    final url =
        await ApiService.uploadAudio(
      File(path),
    );

    if (url == null) {
      return null;
    }

    audioCache[path] = url;

    return url;
  }

  /// =====================================
  /// INIT VIDEO
  /// =====================================

  Future<void> initVideo(
    String url,
  ) async {

    try {

      videoController?.dispose();

      videoController =
          VideoPlayerController.networkUrl(
        Uri.parse(url),
      );

      await videoController!
          .initialize();

      await videoController!
          .setLooping(true);

      await videoController!
          .setVolume(1);

      await videoController!
          .play();

      videoController!
          .addListener(() async {

        if (!mounted) return;

        final v =
            videoController!.value;

        if (!v.isPlaying &&
            !v.isBuffering &&
            v.position <
                v.duration) {

          await videoController!
              .play();
        }

        setState(() {});
      });

      if (!mounted) return;

      setState(() {});

    } catch (e) {

      debugPrint(
        "VIDEO INIT ERROR => $e",
      );
    }
  }

  /// =====================================
  /// GENERATE MOVIE
  /// =====================================

  Future<void>
      generateMovieNow() async {

    /// 🚫 PREVENT MULTIPLE RUNS

    if (loading) return;

    try {

      /// =========================
      /// VALIDATION
      /// =========================

      if (characters.isEmpty) {

        throw Exception(
          "Add at least one character",
        );
      }

      if (scenePromptController.text
          .trim()
          .isEmpty) {

        throw Exception(
          "Scene prompt is empty",
        );
      }

      /// =========================
      /// START LOADING
      /// =========================

      setState(() {

        loading = true;

        finalDialogue = null;
      });

      updateLoading(
        "Uploading characters...",
      );

      /// =========================
      /// CHARACTERS
      /// =========================

      List<Map<String, dynamic>>
          finalCharacters = [];

      for (int i = 0;
          i < characters.length;
          i++) {

        final char =
            characters[i];

        String? imageUrl;

        String? voiceUrl;

        /// IMAGE

        if (char.image != null) {

          imageUrl =
              await cachedUploadImage(
            char.image!.path,
          );
        }

        /// VOICE

        if (char.voice != null) {

          voiceUrl =
              await cachedUploadAudio(
            char.voice!.path,
          );
        }

        if (imageUrl == null ||
            imageUrl
                .trim()
                .isEmpty) {

          throw Exception(
            "Character image upload failed",
          );
        }

        finalCharacters.add({

          "name":
              char.name,

          "gender":
              char.gender,

          "appearance":
              char.appearance,

          "image_url":
              imageUrl,

          "voice_url":
              voiceUrl ?? "",
        });
      }

      /// =========================
      /// GENERATE
      /// =========================

      updateLoading(
        "Generating cinematic AI video...",
      );

      final result =
          await ApiService
              .generateScene(

        prompt:
            scenePromptController.text,

        background:
            backgroundController.text,

        style:
            "ultra realistic cinematic",

        characters:
            finalCharacters,
      );

      print(result);

      /// =========================
      /// NULL RESPONSE
      /// =========================

      if (result == null) {

        throw Exception(
          "No response from backend",
        );
      }

      /// =========================
      /// FAILED
      /// =========================

      if (result["success"] !=
          true) {

        throw Exception(
          "Generation failed",
        );
      }

      /// =========================
      /// VIDEO URL
      /// =========================

      final videoUrl =
          result["video_url"];

      if (videoUrl == null ||
          videoUrl
              .toString()
              .isEmpty) {

        throw Exception(
          "Video generation failed",
        );
      }

      /// =========================
      /// DIALOGUES
      /// =========================

      String dialoguesText = "";

      if (result["dialogues"] !=
          null) {

        final dialogues =
            result["dialogues"]
                as List;

        for (final d
            in dialogues) {

          dialoguesText +=
              "${d["speaker"]}: ${d["text"]}\n\n";
        }
      }

      /// =========================
      /// INIT VIDEO
      /// =========================

      updateLoading(
        "Preparing cinematic replay...",
      );

      await initVideo(videoUrl);

      /// =========================
      /// FINISH
      /// =========================

      if (!mounted) return;

      setState(() {

        finalDialogue =
            dialoguesText;

        loading = false;

        loadingText = "";
      });

    } catch (e) {

      print(
        "GENERATE ERROR => $e",
      );

      if (!mounted) return;

      setState(() {

        loading = false;

        loadingText = "";
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          backgroundColor:
              Colors.red,

          content: Text(
            "ERROR: $e",
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          loading = false;
        });
      }
    }
  }

  /// =====================================
  /// ADD CHARACTER
  /// =====================================

  Future<void>
      showAddCharacterDialog() async {

    final nameController =
        TextEditingController();

    final appearanceController =
        TextEditingController();

    String gender = "male";

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

            content:
                SingleChildScrollView(

              child: Column(

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
                    height: 15,
                  ),

                  DropdownButtonFormField<
                      String>(

                    value: gender,

                    items: const [

                      DropdownMenuItem(
                        value: "male",
                        child: Text(
                          "Male",
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            "female",
                        child: Text(
                          "Female",
                        ),
                      ),
                    ],

                    onChanged: (
                      value,
                    ) {

                      setDialogState(() {

                        gender =
                            value!;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  TextField(

                    controller:
                        appearanceController,

                    maxLines: 3,

                    decoration:
                        const InputDecoration(

                      labelText:
                          "Appearance",
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  ElevatedButton(

                    onPressed:
                        () async {

                      final img =
                          await pickImage();

                      if (img != null) {

                        setDialogState(() {

                          selectedImage =
                              img;
                        });
                      }
                    },

                    child: Text(

                      selectedImage != null

                          ? "Image Selected ✔"

                          : "Pick Image",
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  ElevatedButton(

                    onPressed:
                        () async {

                      final voice =
                          await pickAudio();

                      if (voice != null) {

                        setDialogState(() {

                          selectedVoice =
                              voice;
                        });
                      }
                    },

                    child: Text(

                      selectedVoice != null

                          ? "Voice Selected ✔"

                          : "Pick Voice",
                    ),
                  ),
                ],
              ),
            ),

            actions: [

              ElevatedButton(

                onPressed: () {

                  if (nameController
                      .text
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

                      gender:
                          gender,

                      appearance:
                          appearanceController
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

                child: const Text(
                  "Add",
                ),
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

  Widget characterCard(
    CharacterData char,
    int index,
  ) {

    return Card(

      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      child: ListTile(

        leading:

            char.image != null

                ? CircleAvatar(

                    backgroundImage:
                        FileImage(
                      char.image!,
                    ),
                  )

                : const CircleAvatar(

                    child: Icon(
                      Icons.person,
                    ),
                  ),

        title: Text(
          char.name,
        ),

        subtitle: Text(

          char.appearance
                  .isEmpty

              ? "No appearance"

              : char.appearance,
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

  /// =====================================
  /// BUILD
  /// =====================================

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "AI Cinematic Engine",
        ),
      ),

      floatingActionButton:
          FloatingActionButton(

        onPressed:
            showAddCharacterDialog,

        child: const Icon(
          Icons.add,
        ),
      ),

      body: Stack(

        children: [

          Padding(

            padding:
                const EdgeInsets.all(
              16,
            ),

            child: ListView(

              children: [

                TextField(

                  controller:
                      backgroundController,

                  decoration:
                      const InputDecoration(

                    labelText:
                        "Background",
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                TextField(

                  controller:
                      scenePromptController,

                  minLines: 5,

                  maxLines: 8,

                  decoration:
                      const InputDecoration(

                    labelText:
                        "Scene Prompt",
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

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
                  height: 20,
                ),

                SizedBox(

                  height: 60,

                  child: ElevatedButton(

                    onPressed:
                        loading
                            ? null
                            : generateMovieNow,

                    child: const Text(
                      "Generate AI Movie",
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                if (videoController !=
                        null &&
                    videoController!
                        .value
                        .isInitialized)

                  AspectRatio(

                    aspectRatio:
                        videoController!
                            .value
                            .aspectRatio,

                    child: VideoPlayer(
                      videoController!,
                    ),
                  ),

                const SizedBox(
                  height: 20,
                ),

                if (finalDialogue !=
                    null)

                  SelectableText(
                    finalDialogue!,
                  ),
              ],
            ),
          ),

          if (loading)

            Container(

              color: Colors.black54,

              child: Center(

                child: Column(

                  mainAxisSize:
                      MainAxisSize.min,

                  children: [

                    const CircularProgressIndicator(),

                    const SizedBox(
                      height: 20,
                    ),

                    Text(

                      loadingText,

                      style:
                          const TextStyle(

                        color:
                            Colors.white,

                        fontSize: 18,
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