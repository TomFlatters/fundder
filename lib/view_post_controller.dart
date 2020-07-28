import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/post_widgets/likeBar.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'helper_classes.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'models/post.dart';
import 'share_post_view.dart';
import 'donation/donate_page_controller.dart';
import 'comment_view_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_pages/web_menu.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'video_item.dart';
import 'global_widgets/buttons.dart';

class ViewPost extends StatefulWidget {
  final String postData;
  final LikesModel likesModel;
  ViewPost({this.postData, this.likesModel});

  @override
  _ViewPostState createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> with RouteAware {
  RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  Post postData;

  @override
  void initState() {
    //print(widget.postData);
    _getPost();
    super.initState();
  }

  void _getPost() {
    DatabaseService(uid: widget.postData)
        .getPostById(widget.postData)
        .then((post) => {
              setState(() {
                print("set state");
                print(post);
                postData = post;
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print("View post controller");
    //print(howLongAgo(postData.timestamp));
    return (postData == null)
        ? Loading()
        : Scaffold(
            appBar: kIsWeb == true
                ? null
                : AppBar(
                    centerTitle: true,
                    title: Text(postData.title),
                    actions: <Widget>[
                      new IconButton(
                        icon: new Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(null),
                      )
                    ],
                    leading: new Container(),
                  ),
            body: Column(children: [
              kIsWeb == true ? WebMenu(-1) : Container(),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Container(
                        color: Colors.white,
                        child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  height: 60,
                                  child: Row(
                                    children: <Widget>[
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: AspectRatio(
                                              aspectRatio: 1 / 1,
                                              child: Container(
                                                child: ProfilePic(
                                                    postData.author, 40),
                                                margin: EdgeInsets.all(10.0),
                                              ))),
                                      Expanded(
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              postData.authorUsername,
                                              style: TextStyle(
                                                fontFamily: 'Quicksand',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )),
                                      ),
                                      Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                              margin: EdgeInsets.all(10.0),
                                              child: Text(postData.charity))),
                                    ],
                                  ),
                                ),
                                (postData.imageUrl == null)
                                    ? Container()
                                    : Container(
                                        child: SizedBox(
                                            /*width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              9 /
                                              16,*/
                                            child:
                                                _previewImageVideo(postData)),
                                        margin: EdgeInsets.symmetric(
                                            vertical: 10.0),
                                      ),
                                Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Text(
                                      '£${postData.amountRaised} raised of £${postData.targetAmount} target',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                      top: 5, bottom: 15, left: 10, right: 10),
                                  child: LinearPercentIndicator(
                                    linearStrokeCap: LinearStrokeCap.butt,
                                    lineHeight: 3,
                                    percent: postData.percentRaised(),
                                    backgroundColor: HexColor('CCCCCC'),
                                    progressColor: HexColor('ff6b6c'),
                                  ),
                                ),
                                Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Text(postData.subtitle)),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 20, right: 20, bottom: 20),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 0),
                                  height: 30,
                                  child: Row(children: <Widget>[
                                    Expanded(
                                      //     child: LikeBar(
                                      //   postId: postData.id,
                                      // )
                                      child: ChangeNotifierProvider(
                                          create: (context) =>
                                              widget.likesModel,
                                          child: LikeBar()),
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
                                                    '777',
                                                    textAlign: TextAlign.left,
                                                  )))
                                        ]),
                                        onPressed: () {
                                          /*Navigator.of(context)
                                          .push(_showComments());*/
                                          Navigator.pushNamed(
                                              context,
                                              '/post/' +
                                                  widget.postData +
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
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child:
                                          Text(howLongAgo(postData.timestamp),
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
                                ]),
                                PrimaryFundderButton(
                                    text: 'Donate',
                                    onPressed: () {
                                      /*Navigator.of(context).push(_openDonate());*/
                                      Navigator.pushNamed(
                                          context,
                                          '/post/' +
                                              widget.postData +
                                              '/donate');
                                    }),
                                user.uid != postData.author ||
                                        postData.status != 'fund'
                                    ? Container()
                                    : PrimaryFundderButton(
                                        text: 'Complete Challenge',
                                        onPressed: () {
                                          Navigator.pushNamed(
                                                  context,
                                                  '/post/' +
                                                      widget.postData +
                                                      '/uploadProof')
                                              .then((_) {
                                            // you have come back to your Settings screen
                                            setState(() {
                                              _getPost();
                                            });
                                          });
                                        }),
                              ],
                            )))
                  ],
                ),
              ),
            ]),
          );
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

  Widget _previewImageVideo(Post postData) {
    if (postData.imageUrl.contains('video')) {
      print('initialising video');
      return VideoItem(
        key: UniqueKey(),
        url: postData.imageUrl,
      );
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

  void _showShare() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SharePost();
        });
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)); //Subscribe it here
    super.didChangeDependencies();
  }

  @override
  void didPopNext() {
    print("didPopNext");
    setState(() {
      print("Did pop controller above");
    });
    super.didPopNext();
  }

  @override
  void didPush() {
    print("didPush");
    super.didPush();
  }
}
