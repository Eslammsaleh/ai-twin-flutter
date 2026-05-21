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
  /// =========================
  /// CHARACTERS
  /// =========================

  final List<CharacterData>
      characters = [];

  /// =========================
  /// CONTROLLERS
  /// =========================

  final TextEditingController
      scenePromptController =
      TextEditingController(
    text:
        "Two university friends walk slowly through a modern university campus during sunset while talking emotionally. Students move naturally in the background, trees move softly with the wind, cinematic camera tracking shot, realistic body movement, emotional facial expressions, Hollywood cinematic realism, ultra realistic motion and lighting.",
  );

  final TextEditingController
      backgroundController =
      TextEditingController(
    text:
        "Modern cinematic university campus",
  );

  /// =========================
  /// STATES
  /// =========================

  bool loading = false;

  String loadingText = "";

  String? finalDialogue;

  VideoPlayerController?
  videoController;

  /// =========================
  /// CACHE
  /// =========================

  final Map<String, String>
      imageCache = {};

  final Map<String, String>
      audioCache = {};

  @override
  void dispose() {
    scenePromptController.dispose();

    backgroundController.dispose();

    videoController?.pause();

    videoController?.dispose();

    super.dispose();
  }

  /// =========================
  /// LOADING
  /// =========================

  void updateLoading(
    String text,
  ) {
    if (!mounted) return;

    setState(() {
      loadingText = text;
    });
  }

  /// =========================
  /// IMAGE PICKER
  /// =========================

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

  /// =========================
  /// AUDIO PICKER
  /// =========================

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

  /// =========================
  /// IMAGE CACHE
  /// =========================

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

  /// =========================
  /// AUDIO CACHE
  /// =========================

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

  /// =========================
  /// VIDEO INIT
  /// =========================

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
          .setVolume(1.0);

      await videoController!
          .setLooping(true);

      await videoController!
          .play();

      /// VERY IMPORTANT
      await Future.delayed(
        const Duration(
          milliseconds: 300,
        ),
      );

      /// AUTO RECOVERY + REPAINT

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

  /// =========================
  /// GENERATE MOVIE
  /// =========================

  Future<void>
      generateMovieNow() async {

    try {

      /// VALIDATION

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

      setState(() {

        loading = true;

        finalDialogue = null;
      });

      updateLoading(
        "Uploading characters...",
      );

      /// =====================
      /// CHARACTERS
      /// =====================

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

        if (imageUrl == null) {

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

      /// =====================
      /// GENERATE
      /// =====================

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

      if (result == null) {

        throw Exception(
          "No response from backend",
        );
      }

      if (result["success"] !=
          true) {

        throw Exception(
          "Generation failed",
        );
      }

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

      /// =====================
      /// DIALOGUES
      /// =====================

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

      /// =====================
      /// VIDEO
      /// =====================

      updateLoading(
        "Preparing cinematic replay...",
      );

      await initVideo(videoUrl);

      /// =====================
      /// UI
      /// =====================

      setState(() {

        finalDialogue =
            dialoguesText;

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

          backgroundColor:
              Colors.red,

          content: Text(
            "ERROR: $e",
          ),
        ),
      );
    }
  }

  /// =========================
  /// ADD CHARACTER
  /// =========================

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

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                20,
              ),
            ),

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

                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  DropdownButtonFormField<
                      String>(

                    value: gender,

                    decoration:
                        const InputDecoration(

                      labelText:
                          "Gender",

                      border:
                          OutlineInputBorder(),
                    ),

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
                    height: 20,
                  ),

                  TextField(

                    controller:
                        appearanceController,

                    maxLines: 3,

                    decoration:
                        const InputDecoration(

                      labelText:
                          "Character Appearance",

                      hintText:
                          "Optional but improves realism significantly",

                      border:
                          OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  ElevatedButton.icon(

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

                    icon: const Icon(
                      Icons.image,
                    ),

                    label: Text(

                      selectedImage != null

                          ? "Image Selected ✔"

                          : "Pick Character Image",
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  ElevatedButton.icon(

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

                    icon: const Icon(
                      Icons.mic,
                    ),

                    label: Text(

                      selectedVoice != null

                          ? "Voice Selected ✔"

                          : "Pick Voice (Optional)",
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
                  "Add Character",
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

      elevation: 8,

      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      shape:
          RoundedRectangleBorder(

        borderRadius:
            BorderRadius.circular(
          22,
        ),
      ),

      child: Padding(

        padding:
            const EdgeInsets.all(12),

        child: Row(

          children: [

            char.image != null

                ? ClipRRect(

                    borderRadius:
                        BorderRadius.circular(
                      50,
                    ),

                    child: Image.file(

                      char.image!,

                      width: 70,

                      height: 70,

                      fit: BoxFit.cover,
                    ),
                  )

                : const CircleAvatar(

                    radius: 35,

                    child: Icon(
                      Icons.person,
                    ),
                  ),

            const SizedBox(
              width: 14,
            ),

            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(

                    char.name,

                    style:
                        const TextStyle(

                      fontSize: 18,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    char.gender,
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(

                    char.appearance
                            .isEmpty

                        ? "No appearance description"

                        : char.appearance,

                    maxLines: 2,

                    overflow:
                        TextOverflow
                            .ellipsis,
                  ),
                ],
              ),
            ),

            IconButton(

              icon: const Icon(

                Icons.delete,

                color: Colors.red,
              ),

              onPressed: () {

                setState(() {

                  characters.removeAt(
                    index,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// MAIN UI
  /// =========================

  Widget buildMainUI() {

    return Padding(

      padding:
          const EdgeInsets.all(16),

      child: ListView(

        children: [

          TextField(

            controller:
                backgroundController,

            decoration:
                const InputDecoration(

              labelText:
                  "Scene Background",

              border:
                  OutlineInputBorder(),
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

              hintText:
                  "Describe the cinematic scene...",

              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          ElevatedButton.icon(

            onPressed:
                showAddCharacterDialog,

            icon: const Icon(
              Icons.add,
            ),

            label: const Text(
              "Add Character",
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
            height: 30,
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

                style:
                    TextStyle(

                  fontSize: 18,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 30,
          ),

          /// =========================
          /// VIDEO PLAYER
          /// =========================

          if (videoController != null &&
              videoController!
                  .value
                  .isInitialized)

            Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Container(

                  decoration:
                      BoxDecoration(

                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),

                    boxShadow: [

                      BoxShadow(

                        blurRadius: 25,

                        spreadRadius: 2,

                        offset:
                            const Offset(
                          0,
                          10,
                        ),

                        color:
                            Colors.black26,
                      ),
                    ],
                  ),

                  child: ClipRRect(

                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),

                    child: SizedBox(

                      height: 320,

                      width:
                          double.infinity,

                      child: FittedBox(

                        fit: BoxFit.cover,

                        child: SizedBox(

                          width:
                              videoController!
                                  .value
                                  .size
                                  .width,

                          height:
                              videoController!
                                  .value
                                  .size
                                  .height,

                          child: VideoPlayer(
                            videoController!,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                Row(

                  children: [

                    IconButton(

                      onPressed:
                          () async {

                        if (videoController!
                            .value
                            .isPlaying) {

                          await videoController!
                              .pause();

                        } else {

                          await videoController!
                              .play();
                        }

                        if (!mounted) return;

                        setState(() {});
                      },

                      icon: Icon(

                        videoController!
                                .value
                                .isPlaying

                            ? Icons.pause

                            : Icons.play_arrow,
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    const Text(

                      "AI Cinematic Replay",

                      style: TextStyle(

                        fontSize: 20,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

          const SizedBox(
            height: 20,
          ),

          if (finalDialogue != null)

            Container(

              padding:
                  const EdgeInsets.all(
                16,
              ),

              decoration:
                  BoxDecoration(

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),

                color:
                    Colors.black12,
              ),

              child: SelectableText(

                finalDialogue!,

                style:
                    const TextStyle(

                  height: 1.6,

                  fontSize: 16,
                ),
              ),
            ),
        ],
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
          "AI Cinematic Engine",
        ),

        centerTitle: true,
      ),

      body: Stack(

        children: [

          buildMainUI(),

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

                        fontWeight:
                            FontWeight.bold,
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