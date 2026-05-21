import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

class VideoWidget extends StatefulWidget {
  final String videoUrl;

  final String? audioUrl;

  const VideoWidget({
    super.key,
    required this.videoUrl,
    this.audioUrl,
  });

  @override
  State<VideoWidget> createState() =>
      _VideoWidgetState();
}

class _VideoWidgetState
    extends State<VideoWidget>
    with AutomaticKeepAliveClientMixin {

  late VideoPlayerController
      _controller;

  final AudioPlayer
      _audioPlayer =
      AudioPlayer();

  bool initialized = false;

  bool isMuted = false;

  bool showControls = true;

  bool hasError = false;

  bool rebuilding = false;

  /// IMPORTANT FIX
  bool pausedByUser = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    initMedia();
  }

  /// =========================
  /// INIT MEDIA
  /// =========================

  Future<void> initMedia() async {

    try {

      debugPrint(
        "VIDEO URL => ${widget.videoUrl}",
      );

      /// VIDEO

      _controller =
          VideoPlayerController.networkUrl(
        Uri.parse(
          widget.videoUrl,
        ),
      );

      await _controller.initialize();

      await _controller.setLooping(
        true,
      );

      await _controller.setVolume(
        1.0,
      );

      await _controller.play();

      await Future.delayed(
        const Duration(
          milliseconds: 300,
        ),
      );

      /// AUDIO

      if (widget.audioUrl != null &&
          widget.audioUrl!
              .trim()
              .isNotEmpty) {

        await _audioPlayer.setUrl(
          widget.audioUrl!,
        );

        await _audioPlayer
            .setLoopMode(
          LoopMode.one,
        );

        await _audioPlayer.play();
      }

      /// LISTENER

      _controller.addListener(() async {

        if (!_controller
            .value
            .isInitialized) {
          return;
        }

        final v =
            _controller.value;

        /// AUTO RECOVERY

        if (!pausedByUser &&
            !v.isPlaying &&
            !v.isBuffering &&
            v.position <
                v.duration) {

          debugPrint(
            "AUTO PLAY RECOVERY",
          );

          await _controller.play();
        }

        /// REDUCE REBUILDS

        if (!rebuilding &&
            mounted) {

          rebuilding = true;

          setState(() {});

          Future.delayed(
            const Duration(
              milliseconds: 150,
            ),
            () {
              rebuilding = false;
            },
          );
        }
      });

      if (!mounted) return;

      setState(() {

        initialized = true;
      });

      debugPrint(
        "VIDEO INITIALIZED SUCCESSFULLY",
      );

    } catch (e) {

      debugPrint(
        "VIDEO INIT ERROR => $e",
      );

      hasError = true;

      if (mounted) {
        setState(() {});
      }
    }
  }

  /// =========================
  /// PLAY / PAUSE
  /// =========================

  Future<void>
      togglePlayPause() async {

    try {

      if (_controller
          .value
          .isPlaying) {

        /// USER PAUSE

        pausedByUser = true;

        await _controller.pause();

        await _audioPlayer.pause();

      } else {

        /// USER RESUME

        pausedByUser = false;

        await _controller.play();

        if (widget.audioUrl !=
                null &&
            widget.audioUrl!
                .isNotEmpty) {

          await _audioPlayer.play();
        }
      }

      if (!mounted) return;

      setState(() {});

    } catch (e) {

      debugPrint(
        "PLAY ERROR => $e",
      );
    }
  }

  /// =========================
  /// MUTE
  /// =========================

  Future<void> toggleMute() async {

    try {

      isMuted = !isMuted;

      await _controller.setVolume(
        isMuted ? 0 : 1,
      );

      await _audioPlayer.setVolume(
        isMuted ? 0 : 1,
      );

      if (!mounted) return;

      setState(() {});

    } catch (e) {

      debugPrint(
        "MUTE ERROR => $e",
      );
    }
  }

  /// =========================
  /// DISPOSE
  /// =========================

  @override
  void dispose() {

    try {

      _controller.pause();

      _audioPlayer.stop();

      _controller.dispose();

      _audioPlayer.dispose();

    } catch (_) {}

    super.dispose();
  }

  /// =========================
  /// LOADING
  /// =========================

  Widget buildLoading() {

    return Container(

      height: 320,

      decoration: BoxDecoration(

        color: Colors.black,

        borderRadius:
            BorderRadius.circular(
          24,
        ),
      ),

      child: const Center(

        child:
            CircularProgressIndicator(),
      ),
    );
  }

  /// =========================
  /// ERROR
  /// =========================

  Widget buildError() {

    return Container(

      height: 320,

      decoration: BoxDecoration(

        color: Colors.black,

        borderRadius:
            BorderRadius.circular(
          24,
        ),
      ),

      child: const Center(

        child: Column(

          mainAxisSize:
              MainAxisSize.min,

          children: [

            Icon(
              Icons.error_outline,

              color: Colors.red,

              size: 60,
            ),

            SizedBox(height: 16),

            Text(

              "Failed to load video",

              style: TextStyle(

                color: Colors.white,

                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// CONTROLS
  /// =========================

  Widget buildControls() {

    return Positioned(

      bottom: 0,
      left: 0,
      right: 0,

      child: AnimatedOpacity(

        duration:
            const Duration(
          milliseconds: 250,
        ),

        opacity:
            showControls ? 1 : 0,

        child: Container(

          padding:
              const EdgeInsets.all(
            12,
          ),

          decoration:
              const BoxDecoration(

            gradient: LinearGradient(

              begin:
                  Alignment.bottomCenter,

              end:
                  Alignment.topCenter,

              colors: [

                Colors.black87,

                Colors.transparent,
              ],
            ),
          ),

          child: Row(

            children: [

              /// PLAY / PAUSE

              IconButton(

                onPressed:
                    togglePlayPause,

                icon: Icon(

                  _controller
                          .value
                          .isPlaying

                      ? Icons.pause

                      : Icons.play_arrow,

                  color:
                      Colors.white,

                  size: 32,
                ),
              ),

              /// MUTE

              IconButton(

                onPressed:
                    toggleMute,

                icon: Icon(

                  isMuted

                      ? Icons.volume_off

                      : Icons.volume_up,

                  color:
                      Colors.white,
                ),
              ),

              /// PROGRESS

              Expanded(

                child:
                    VideoProgressIndicator(

                  _controller,

                  allowScrubbing:
                      true,

                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =========================
  /// BUILD
  /// =========================

  @override
  Widget build(
    BuildContext context,
  ) {

    super.build(context);

    /// ERROR

    if (hasError) {

      return buildError();
    }

    /// LOADING

    if (!initialized ||
        !_controller
            .value
            .isInitialized) {

      return buildLoading();
    }

    /// VIDEO

    return GestureDetector(

      onTap: () {

        setState(() {

          showControls =
              !showControls;
        });
      },

      child: Container(

        margin:
            const EdgeInsets.symmetric(
          vertical: 12,
        ),

        decoration: BoxDecoration(

          color: Colors.black,

          borderRadius:
              BorderRadius.circular(
            24,
          ),

          boxShadow: [

            BoxShadow(

              color:
                  Colors.black26,

              blurRadius: 25,

              spreadRadius: 2,

              offset:
                  const Offset(
                0,
                12,
              ),
            ),
          ],
        ),

        child: ClipRRect(

          borderRadius:
              BorderRadius.circular(
            24,
          ),

          child: Stack(

            alignment:
                Alignment.center,

            children: [

              /// VIDEO

              SizedBox(

                height: 320,

                width:
                    double.infinity,

                child: FittedBox(

                  fit: BoxFit.cover,

                  child: SizedBox(

                    width:
                        _controller
                            .value
                            .size
                            .width,

                    height:
                        _controller
                            .value
                            .size
                            .height,

                    child: VideoPlayer(
                      _controller,
                    ),
                  ),
                ),
              ),

              /// BIG PLAY BUTTON

              if (!_controller
                  .value
                  .isPlaying)

                GestureDetector(

                  onTap:
                      togglePlayPause,

                  child: Container(

                    width: 80,
                    height: 80,

                    decoration:
                        BoxDecoration(

                      color:
                          Colors.black54,

                      shape:
                          BoxShape.circle,
                    ),

                    child: const Icon(

                      Icons.play_arrow,

                      color:
                          Colors.white,

                      size: 48,
                    ),
                  ),
                ),

              /// CONTROLS

              buildControls(),
            ],
          ),
        ),
      ),
    );
  }
}