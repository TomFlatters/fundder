import 'package:flutter/material.dart';

import 'package:fundder/post_widgets/commentBar.dart';
import 'package:fundder/post_widgets/likeBar.dart';
import 'package:fundder/post_widgets/postBody.dart';
import 'package:fundder/post_widgets/postHeader.dart';
import 'package:fundder/post_widgets/shareBar.dart';
import 'package:fundder/services/likes.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'post_widgets/postHeader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/post.dart';
import 'shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_pages/web_menu.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'global_widgets/buttons.dart';

class ViewPost extends StatelessWidget with RouteAware {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  final Post postData;
  // int noLikes;
  // bool hasLiked;

  ViewPost(
    this.postData,
    /*{this.noLikes, this.hasLiked}*/
  );

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
                child: ShareBar(
                  postId: postData.id,
                  postTitle: postData.title,
                ),
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
                : Container() // Decided against allowing deletion on view post controller for now as passing the reloading to feed is difficult
            /*FlatButton(
                    onPressed: () {
                      print('button pressed');
                      _showDeleteDialog(postData, context);
                    },
                    child: Text('Delete',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        )),
                  ),*/
          ])
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    LikesService likesService = LikesService(uid: user.uid);

    bool initiallyHasLiked;
    int initialLikesNo;

    print("View post controller");

    if (postData == null) {
      return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(""),
            actions: <Widget>[
              new IconButton(
                  icon: new Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ],
            leading: new Container(),
          ),
          body: Container(
              child: Text(
                  "Error retrieving post: either the post does not exist, or your internet is not connected")));
    } else {
      return WillPopScope(
          onWillPop: () async => false,
          child: FutureBuilder(
              future: likesService.hasUserLikedPost(postData.id),
              builder: (context, hasLiked) {
                if (hasLiked.connectionState == ConnectionState.done) {
                  initiallyHasLiked = hasLiked.data;
                  return FutureBuilder(
                      future: likesService.noOfLikes(postData.id),
                      builder: (context, noLikes) {
                        if (noLikes.connectionState == ConnectionState.done) {
                          initialLikesNo = noLikes.data;
                          var likesModel = LikesModel(
                              initiallyHasLiked, initialLikesNo,
                              uid: user.uid, postId: postData.id);
                          print(
                              'In viewpost, just made a likesModel and the values are ${likesModel.noLikes} and ${likesModel.isLiked}');
                          return Scaffold(
                            appBar: kIsWeb == true
                                ? null
                                : AppBar(
                                    centerTitle: true,
                                    title: Text(postData.title),
                                    actions: <Widget>[
                                      new IconButton(
                                          icon: new Icon(Icons.close),
                                          onPressed: () {
                                            Map newState = {
                                              'noLikes': likesModel.noLikes,
                                              'isLiked': likesModel.isLiked
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
                                            margin: EdgeInsets.symmetric(
                                                vertical: 10.0),
                                            child: Column(
                                              children: <Widget>[
                                                createPostUI(
                                                    postData,
                                                    likesModel,
                                                    user.uid,
                                                    context),
                                                PrimaryFundderButton(
                                                    text: 'Donate',
                                                    onPressed: () async {
                                                      //This is the old code for redirecting to a donation page within the app
                                                      //apple and google don't allow this without taking a 30% cut

                                                      /*Navigator.of(context).push(_openDonate());*/
                                                      // Navigator.pushNamed(
                                                      //     context,
                                                      //     '/post/' +
                                                      //         postData.id +
                                                      //         '/donate');
                                                      var url =
                                                          "https://fundder.co/";
                                                      if (await canLaunch(
                                                          url)) {
                                                        await launch(
                                                          url,
                                                          forceSafariVC: false,
                                                          forceWebView: false,
                                                        );
                                                      } else {
                                                        throw 'Could not launch $url';
                                                      }
                                                    }),
                                                user.uid != postData.author ||
                                                        postData.status !=
                                                            'fund'
                                                    ? Container()
                                                    : PrimaryFundderButton(
                                                        text:
                                                            'Complete Challenge',
                                                        onPressed: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/post/' +
                                                                  postData.id +
                                                                  '/uploadProof');
                                                        }),
                                              ],
                                            )))
                                  ],
                                ),
                              ),
                            ]),
                          );
                        } else {
                          return Loading();
                        }
                      });
                } else {
                  return Loading();
                }
              }));
    }
  }

  // @override
  // void didChangeDependencies() {
  //   routeObserver.subscribe(this, ModalRoute.of(context)); //Subscribe it here
  //   super.didChangeDependencies();
  // }

  // @override
  // void didPopNext() {
  //   print("didPopNext");
  //   setState(() {
  //     print("Did pop controller above");
  //   });
  //   super.didPopNext();
  // }

  // @override
  // void didPush() {
  //   print("didPush");
  //   super.didPush();
  // }

  Future<void> _showDeleteDialog(Post post, context) async {
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
}
