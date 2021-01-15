import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/post_widgets/postBody.dart';
import 'package:fundder/post_widgets/postHeader.dart';
import 'package:fundder/models/post.dart';
import 'package:fundder/models/charity.dart';
import 'package:fundder/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/media_upload.dart';
import 'package:video_player/video_player.dart';

//Technically passing all these parameters to do with state is redundant now
// but this has been kept as legacy to save time in getting version 3.0.0 out.
class PostPreview extends StatefulWidget {
  final bool isPreviewForChallenges;
  final Charity charity;
  final String authorUid;
  final String authorUsername;
  final Widget imageView;
  final String title;
  final String subtitle;
  final int selected;
  final String targetAmount;
  final List<String> hashtags;
  PostPreview(
      {this.isPreviewForChallenges,
      this.charity,
      this.authorUid,
      this.authorUsername,
      this.imageView,
      this.title,
      this.subtitle,
      this.selected,
      this.targetAmount,
      this.hashtags});
  @override
  _PostPreviewState createState() => _PostPreviewState();
}

class _PostPreviewState extends State<PostPreview> {
  Function _disposeVideoController = () {};
  @override
  void dispose() {
    _disposeVideoController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaState = Provider.of<MediaStateManager>(context, listen: false);
    final height = (MediaQuery.of(context).size.height) * 2 / 5;
    final width = MediaQuery.of(context).size.width;
    final user = Provider.of<User>(context);
    this._disposeVideoController = mediaState.removeVideoPlayer;
    return ListView(children: <Widget>[
      Container(
        color: Colors.grey[200],
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white,
          ),
          margin: EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                color: Colors.white,
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Text(
                  (widget.isPreviewForChallenges)
                      ? 'This is what your challenge will look like:'
                      : 'This is what your post would look like:',
                  style: TextStyle(
                    fontFamily: 'Founders Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              PostHeader(
                  postAuthorId: widget.authorUid,
                  postAuthorUserName: widget.authorUsername,
                  targetCharity: widget.charity.id,
                  charityLogo: widget.charity.image),
              (mediaState.hasVideo)
                  ? FutureBuilder(
                      future: mediaState.videoController.initialize(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          mediaState.videoController.play();
                          mediaState.videoController.setVolume(0);
                          mediaState.videoController.setLooping(true);
                          return AspectRatio(
                              child: VideoPlayer(mediaState.videoController),
                              aspectRatio:
                                  mediaState.videoController.value.aspectRatio);
                        } else {
                          return Container(
                              child: Loading(),
                              constraints: BoxConstraints(
                                minWidth: width,
                                minHeight: height,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ));
                        }
                      },
                    )
                  : Container(
                      child: SizedBox(child: widget.imageView),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
              PostBody(
                likesManager: null,
                maxLines: 99999999,
                postData: Post(
                    isPrivate: user.isPrivate,
                    title: widget.title,
                    subtitle: widget.subtitle,
                    hashtags: widget.hashtags,
                    charity: widget.charity.name,
                    moneyRaised: 0,
                    targetAmount:
                        widget.selected != 1 ? widget.targetAmount : '-1'),
              )
            ],
          ),
        ),
      ),
    ]);
  }
}
