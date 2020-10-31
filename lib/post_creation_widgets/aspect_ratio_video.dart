import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final VideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller.value.initialized) {
      initialized = controller.value.initialized;
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return VisibilityDetector(
          key: UniqueKey(),
          onVisibilityChanged: (VisibilityInfo info) {
            debugPrint("${info.visibleFraction} of my widget is visible");
            if (mounted) {
              if (info.visibleFraction < 0.3) {
                controller.pause();
              } else {
                controller.play();
              }
            }
          },
          child: Center(
              child: GestureDetector(
            onTap: _playPause,
            child: controller.value.initialized
                ? AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: Container(
                      //constraints: BoxConstraints(
                      //minHeight:
                      //   MediaQuery.of(context).size.width * 9 / 16),
                      child: VideoPlayer(
                        controller,
                      ),
                    ),
                  )
                : new CircularProgressIndicator(),
          ) //)/*AspectRatio(
              /*aspectRatio: controller.value?.aspectRatio,
          child: VideoPlayer(controller),*/
              ));
      //);
    } else {
      return Container();
    }
  }

  _playPause() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }
}
