import 'package:flutter/material.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'shared/loading.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'custom_cache_manager.dart';
import 'package:better_player/better_player.dart';

class VideoItem extends StatefulWidget {
  final String url;
  final double aspectRatio;

  VideoItem({Key key, this.url, @required this.aspectRatio}) : super(key: key);
  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> with RouteAware {
  RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  BetterPlayerListVideoPlayerController controller;
  BetterPlayerDataSource _dataSource;

  @override
  void initState() {
    controller = BetterPlayerListVideoPlayerController();
    _setVideoController(widget.url);
    super.initState();
  }

  void _setVideoController(String url) async {
    try {
      final cacheManager = CustomCacheManager();

      FileInfo fileInfo;

      fileInfo = await cacheManager
          .getFileFromCache(url); // Get video from cache first

      if (fileInfo?.file == null) {
        setState(() {
          _dataSource = BetterPlayerDataSource(
              BetterPlayerDataSourceType.NETWORK, widget.url);
        });
        cacheManager
            .downloadFile(url)
            .then((value) => print('download complete'));
        /*videoPlayerController = VideoPlayerController.network(url)
          ..initialize().then((_) {
            chewieController = ChewieController(
              videoPlayerController: videoPlayerController,
              aspectRatio: widget.aspectRatio,
              autoPlay: false,
              looping: true,
            );
            setState(() {});
            cacheManager.downloadFile(url); // Download video if not cached yet
          });*/
      } else {
        print('getting from cache');
        fileInfo = await cacheManager.getFileFromCache(url);
        if (fileInfo != null) {
          setState(() {
            _dataSource = BetterPlayerDataSource(
                BetterPlayerDataSourceType.FILE, fileInfo.file.path.toString());
          });
        }
        /*videoPlayerController = VideoPlayerController.file(fileInfo?.file)
          ..initialize().then((_) {
            chewieController = ChewieController(
              videoPlayerController: videoPlayerController,
              aspectRatio: widget.aspectRatio,
              autoPlay: false,
              looping: true,
            );
            setState(() {});
          });*/
      }
    } catch (e) {
      throw (e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return /*VisibilityDetector(
        key: UniqueKey(),
        onVisibilityChanged: (VisibilityInfo info) {
          debugPrint("${info.visibleFraction} of my widget is visible");
          if (mounted) {
            if (info.visibleFraction < 0.3) {
              chewieController?.pause();
            } else {
              chewieController?.play();
            }
          }
        },
        child: */ //Center(
        /*child:*/
        GestureDetector(
            onTap: _playPause,
            child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: _dataSource != null
                    ? BetterPlayerListVideoPlayer(
                        _dataSource,
                        configuration: BetterPlayerConfiguration(
                          autoPlay: false,
                          aspectRatio: widget.aspectRatio,
                          fit: BoxFit.fill,
                        ),
                        key: UniqueKey(),
                        playFraction: 0.3,
                        betterPlayerListVideoPlayerController: controller,
                      )
                    : Loading()));
    /*videoPlayerController != null &&
                  videoPlayerController.value.initialized
              ? GestureDetector(
                  onTap: _playPause,
                  child: Container(
                      child: videoPlayerController != null &&
                              videoPlayerController.value.initialized
                          ? Chewie(
                              controller: chewieController,
                            )
                          : Container()),
                ) //)
              //])
              : Loading(),*/
    //));
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
    controller?.pause();
    super.didPush();
  }

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext() {
    print("didPushNext");
    controller?.pause();
    super.didPushNext();
  }

  @override
  void dispose() {
    //routeObserver.unsubscribe(this);
    super.dispose();
    if (mounted && videoPlayerController != null) {
      videoPlayerController.dispose();
      chewieController.dispose();
    }
  }

  _playPause() {
    if (videoPlayerController != null &&
        videoPlayerController.value.isPlaying) {
      controller?.pause();
    } else {
      controller?.play();
    }
  }
}
