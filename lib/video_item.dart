import 'package:flutter/material.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'shared/loading.dart';

class VideoItem extends StatefulWidget {
  final String url;

  VideoItem(this.url);
  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> with RouteAware {
  RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  CachedVideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CachedVideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        //_controller.play();
        _controller.setLooping(true);
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: UniqueKey(),
        onVisibilityChanged: (VisibilityInfo info) {
          debugPrint("${info.visibleFraction} of my widget is visible");
          if (info.visibleFraction < 0.3) {
            _controller.pause();
          } else {
            _controller.play();
          }
        },
        child: Center(
          child: _controller.value.initialized
              ? GestureDetector(
                  onTap: _playPause,
                  child: _controller.value.initialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: CachedVideoPlayer(_controller),
                        )
                      : Container(),
                ) //)
              //])
              : Loading(),
        ));
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)); //Subscribe it here
    super.didChangeDependencies();
  }

  /// Called when the current route has been popped off.
  @override
  void didPop() {
    print("didPop");
    super.didPop();
  }

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext() {
    print("didPopNext");
    super.didPopNext();
  }

  /// Called when the current route has been pushed.
  @override
  void didPush() {
    print("didPush");
    _controller.pause();
    super.didPush();
  }

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext() {
    print("didPushNext");
    _controller.pause();
    super.didPushNext();
  }

  @override
  void dispose() {
    //routeObserver.unsubscribe(this);
    super.dispose();
    _controller.dispose();
  }

  _playPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }
}
