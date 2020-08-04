import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/post_widgets/commentBar.dart';
import 'package:fundder/post_widgets/likeBar.dart';
import 'package:fundder/post_widgets/postBody.dart';
import 'package:fundder/post_widgets/postHeader.dart';
import 'package:fundder/post_widgets/shareBar.dart';
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

class ViewPost extends StatelessWidget with RouteAware {
  RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  final Post postData;
  int noLikes;
  bool hasLiked;

  ViewPost(this.postData, {this.noLikes, this.hasLiked});

  Container createPostUI(
      Post postData, LikesModel likesModel, String uid, context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 0),
        child: Column(children: <Widget>[
          PostHeader(
            postAuthorId: postData.author,
            postAuthorUserName: postData.authorUsername,
            targetCharity: postData.charity,
          ),
          PostBody(postData: postData),
          Container(
            //action bar
            key: GlobalKey(),
            height: 30,
            child: Row(children: <Widget>[
              Expanded(
                //like bar
                child: ChangeNotifierProvider(
                    create: (context) => likesModel, child: LikeBar()),
              ),
              Expanded(
                  child: Align(
                alignment: Alignment.centerLeft,
                child: CommentButton(
                  pid: postData.id,
                ),
              )),
              Expanded(
                child: ShareBar(),
              ),
            ]),
          ),
          Row(children: [
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.all(10),
                child: Text(
                  howLongAgo(postData.timestamp),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            postData.author != uid
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
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print("View post controller");
    //print(howLongAgo(postId.timestamp));
    return (postId == null)
        ? Loading()
        : Scaffold(
            appBar: kIsWeb == true
                ? null
                : AppBar(
                    centerTitle: true,
                    title: Text(postId.title),
                    actions: <Widget>[
                      new IconButton(
                          icon: new Icon(Icons.close),
                          onPressed: () {
                            Map newState = {
                              'noLikes': widget.likesModel.noLikes,
                              'isLiked': widget.likesModel.isLiked
                            };

                            Navigator.of(context).pop(newState);
                          })
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
                                                    postId.author, 40),
                                                margin: EdgeInsets.all(10.0),
                                              ))),
                                      Expanded(
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              postId.authorUsername,
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
                                              child: Text(postId.charity))),
                                    ],
                                  ),
                                ),
                                (postId.imageUrl == null)
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
                                            child: _previewImageVideo(postId)),
                                        margin: EdgeInsets.symmetric(
                                            vertical: 10.0),
                                      ),
                                Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Text(
                                      '£${postId.amountRaised} raised of £${postId.targetAmount} target',
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
                                    percent: postId.percentRaised(),
                                    backgroundColor: HexColor('CCCCCC'),
                                    progressColor: HexColor('ff6b6c'),
                                  ),
                                ),
                                Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Text(postId.subtitle)),
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
                                      child: ChangeNotifierProvider(
                                          create: (context) =>
                                              widget.likesModel,
                                          child: LikeBar()),
                                    ),
                                    Expanded(
                                        child: CommentButton(
                                      pid: postId.id,
                                    )),
                                    Expanded(
                                      child: ShareBar(),
                                    )
                                  ]),
                                ),
                                Row(children: [
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: Text(howLongAgo(postId.timestamp),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          )),
                                    ),
                                  ),
                                  postId.author != user.uid
                                      ? Container()
                                      : FlatButton(
                                          onPressed: () {
                                            print('button pressed');
                                            _showDeleteDialog(postId);
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
                                      Navigator.pushNamed(context,
                                          '/post/' + widget.postId + '/donate');
                                    }),
                                user.uid != postId.author ||
                                        postId.status != 'fund'
                                    ? Container()
                                    : PrimaryFundderButton(
                                        text: 'Complete Challenge',
                                        onPressed: () {
                                          Navigator.pushNamed(
                                                  context,
                                                  '/post/' +
                                                      widget.postId +
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

  Widget _previewImageVideo(Post postId) {
    if (postId.imageUrl.contains('video')) {
      print('initialising video');
      return VideoItem(
        key: UniqueKey(),
        url: postId.imageUrl,
      );
    } else {
      return kIsWeb == true
          ? Image.network(postId.imageUrl)
          : CachedNetworkImage(
              imageUrl: (postId.imageUrl != null)
                  ? postId.imageUrl
                  : 'https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg',
              placeholder: (context, url) => Loading(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            );
    }
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
