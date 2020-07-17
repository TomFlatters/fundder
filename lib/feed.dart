import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'models/post.dart';
import 'view_post_controller.dart';
import 'share_post_view.dart';
import 'helper_classes.dart';
import 'comment_view_controller.dart';
import 'other_user_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:video_player/video_player.dart';
import 'package:cached_video_player/cached_video_player.dart';

class FeedView extends StatefulWidget {
  @override
  _FeedViewState createState() => _FeedViewState();

  final Color colorChoice;
  final String feedChoice;
  final String identifier;
  final Stream<List<Post>> postsStream;
  FeedView(
      this.feedChoice, this.identifier, this.colorChoice, this.postsStream);
}

class _FeedViewState extends State<FeedView> {
  ScrollPhysics physics;

  @override
  void initState() {
    super.initState();
    if (widget.feedChoice == 'user') {
      physics = NeverScrollableScrollPhysics();
      print('user');
    } else {
      physics = AlwaysScrollableScrollPhysics();
      print('nonuser');
    }
  }

  @override
  void didUpdateWidget(FeedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feedChoice == 'user') {
      physics = NeverScrollableScrollPhysics();
      print('user');
    } else {
      physics = AlwaysScrollableScrollPhysics();
      print('nonuser');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return new StreamBuilder(
        stream: widget.postsStream,
        // widget.feedChoice == 'user'
        //   ? Firestore.instance.collection("posts").where("author", isEqualTo: widget.identifier).snapshots()
        //   : Firestore.instance.collection("posts").snapshots(),
        builder: (context, snapshot) {
          // print(snapshot.data);
          if (!snapshot.hasData) {
            return Text("No data...");
          } else {
            return ListView.separated(
              physics: physics,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 10.0),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Post postData = snapshot.data[index];
                // print(postData);
                return GestureDetector(
                  child: Container(
                      color: Colors.white,
                      child: Container(
                          margin: EdgeInsets.only(left: 0, right: 0, top: 0),
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 60,
                                child: Row(
                                  children: <Widget>[
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: GestureDetector(
                                          child: AspectRatio(
                                              aspectRatio: 1 / 1,
                                              child: Container(
                                                child: ProfilePic(
                                                    postData.author, 40),
                                                margin: EdgeInsets.all(10.0),
                                              )),
                                          onTap: () {
                                            print('/user/' + postData.author);
                                            Navigator.pushNamed(context,
                                                '/user/' + postData.author);
                                          },
                                        )),
                                    Expanded(
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(postData.author,
                                                style: TextStyle(
                                                  fontFamily: 'Quicksand',
                                                  fontWeight: FontWeight.w600,
                                                )))),
                                    Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                            margin: EdgeInsets.all(10.0),
                                            child: Text(postData.charity))),
                                  ],
                                ),
                              ),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.all(10),
                                  child: Text(postData.subtitle)),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Text(
                                    '£${postData.amountRaised} raised of £${postData.targetAmount} target',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                              Container(
                                //alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(
                                    top: 5, bottom: 15, left: 0, right: 0),
                                child: LinearPercentIndicator(
                                  linearStrokeCap: LinearStrokeCap.butt,
                                  lineHeight: 3,
                                  percent: postData.percentRaised(),
                                  backgroundColor: HexColor('CCCCCC'),
                                  progressColor: HexColor('ff6b6c'),
                                ),
                              ),
                              (postData.imageUrl == null)
                                  ? Container()
                                  : Container(
                                      /*constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                              .size
                                              .width),*/
                                      child: SizedBox(
                                          /*width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                1 /
                                                1,*/
                                          child: _previewImageVideo(postData)),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10.0),
                                    ),
                              Container(
                                height: 30,
                                child: Row(children: <Widget>[
                                  Expanded(
                                    child: FlatButton(
                                      child: Row(children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          padding: const EdgeInsets.all(0.0),
                                          child: postData.likes
                                                  .contains(user.uid)
                                              ? Image.asset(
                                                  'assets/images/like_selected.png')
                                              : Image.asset(
                                                  'assets/images/like.png'),
                                        ),
                                        Expanded(
                                            child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  postData.likes.length
                                                      .toString(),
                                                  textAlign: TextAlign.left,
                                                )))
                                      ]),
                                      onPressed: () {
                                        /*final snackBar = SnackBar(
                                            content: Text("Like passed"));
                                        Scaffold.of(context)
                                            .showSnackBar(snackBar);*/
                                        if (postData.likes.contains(user.uid) ==
                                            true) {
                                          DatabaseService(uid: user.uid)
                                              .removeLikefromPost(postData);
                                        } else {
                                          DatabaseService(uid: user.uid)
                                              .addLiketoPost(postData);
                                        }
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: FlatButton(
                                      child: Row(children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          padding: const EdgeInsets.all(0.0),
                                          child: Image.asset(
                                              'assets/images/comment.png'),
                                        ),
                                        Expanded(
                                            child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  postData.comments.length
                                                      .toString(),
                                                  textAlign: TextAlign.left,
                                                )))
                                      ]),
                                      onPressed: () {
                                        /*Navigator.of(context)
                                            .push(_showComments());*/
                                        Navigator.pushNamed(
                                            context,
                                            '/post/' +
                                                postData.id +
                                                '/comments');
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: FlatButton(
                                      child: Row(children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          padding: const EdgeInsets.all(0.0),
                                          child: Image.asset(
                                              'assets/images/share.png'),
                                        ),
                                        Expanded(
                                            child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  'Share',
                                                  textAlign: TextAlign.left,
                                                )))
                                      ]),
                                      onPressed: () {
                                        _showShare();
                                      },
                                    ),
                                  )
                                ]),
                              ),
                              Row(children: [
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.all(10),
                                    child: Text(howLongAgo(postData.timestamp),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        )),
                                  ),
                                ),
                                postData.author != user.uid
                                    ? Container()
                                    : FlatButton(
                                        onPressed: () {
                                          print('button pressed');
                                          _showDeleteDialog(postData);
                                        },
                                        child: Text('Delete',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            )),
                                      ),
                              ])
                            ],
                          ))),
                  onTap: () {
                    Navigator.pushNamed(context, '/post/' + postData.id);
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 10,
                );
              },
            );
          }
        });
  }

  Widget _previewImageVideo(Post postData) {
    if (postData.imageUrl.contains('video')) {
      print('initialising video');
      return VideoItem(postData.imageUrl);
    } else {
      return kIsWeb == true
          ? Image.network(postData.imageUrl)
          : CachedNetworkImage(
              imageUrl: (postData.imageUrl != null)
                  ? postData.imageUrl
                  : 'https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg',
              placeholder: (context, url) => Loading(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            );
    }
  }

  Future<void> _showDeleteDialog(Post post) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Post?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Once you delete this post, all the money donated will be refunded unless you have uploaded proof of challenge completion. This cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Delete'),
              onPressed: () {
                Firestore.instance
                    .collection('posts')
                    .document(post.id)
                    .delete()
                    .then((value) {
                  Navigator.of(context).pop();
                });
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showShare() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SharePost();
        });
  }

  List<Post> _postsDataFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      //print(doc.data);
      return Post(
        author: doc.data['author'],
        title: doc.data['title'],
        charity: doc.data['charity'],
        amountRaised: doc.data['amountRaised'],
        targetAmount: doc.data['targetAmount'],
        likes: doc.data['likes'],
        comments: doc.data['comments'],
        subtitle: doc.data['subtitle'],
        timestamp: doc.data['timestamp'],
        id: doc.documentID,
      );
    }).toList();
  }
}

class VideoItem extends StatefulWidget {
  final String url;

  VideoItem(this.url);
  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  CachedVideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CachedVideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.initialized
          ? /*Stack(children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),*/
          /*Center(
                  child: */
          GestureDetector(
              onTap: _playPause,
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: CachedVideoPlayer(_controller),
              ),
            ) //)
          //])
          : Container(),
    );
  }

  @override
  void dispose() {
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
