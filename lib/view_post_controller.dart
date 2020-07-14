import 'package:flutter/material.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'helper_classes.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'models/post.dart';
import 'share_post_view.dart';
import 'donate_page_controller.dart';
import 'comment_view_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_pages/web_menu.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';

class ViewPost extends StatefulWidget {
  final String postData;
  ViewPost({this.postData});

  @override
  _ViewPostState createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  Post postData;

  @override
  void initState() {
    //print(widget.postData);
    //_getPost();
    DatabaseService(uid: widget.postData)
        .getPostById(widget.postData)
        .then((post) => {
              setState(() {
                print("set state");
                print(post);
                postData = post;
              })
            });
    super.initState();
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
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            postData.author,
                                            style: TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )),
                                      Expanded(
                                          child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                  margin: EdgeInsets.all(10.0),
                                                  child:
                                                      Text(postData.charity)))),
                                    ],
                                  ),
                                ),
                                (postData.imageUrl == null)
                                    ? Container()
                                    : Container(
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              9 /
                                              16,
                                          child: kIsWeb == true
                                              ? Image.network(postData.imageUrl)
                                              : CachedNetworkImage(
                                                  imageUrl: (postData
                                                              .imageUrl !=
                                                          null)
                                                      ? postData.imageUrl
                                                      : 'https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg',
                                                  placeholder: (context, url) =>
                                                      Loading(),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ), //Image.network('https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg'),
                                        ),
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
                                  padding: EdgeInsets.all(20),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 0),
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
                                          if (postData.likes
                                                  .contains(user.uid) ==
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
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  child: Text(howLongAgo(postData.timestamp),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      )),
                                ),
                                GestureDetector(
                                    child: Container(
                                      width: 250,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12, /*horizontal: 30*/
                                      ),
                                      margin: EdgeInsets.only(
                                          left: 50, right: 50, bottom: 20),
                                      decoration: BoxDecoration(
                                        color: HexColor('ff6b6c'),
                                        border: Border.all(
                                            color: HexColor('ff6b6c'),
                                            width: 1),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                      child: Text(
                                        "Donate",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      /*Navigator.of(context).push(_openDonate());*/
                                      Navigator.pushNamed(
                                          context,
                                          '/post/' +
                                              widget.postData +
                                              '/donate');
                                    }),
                                user.uid != postData.author
                                    ? Container()
                                    : GestureDetector(
                                        child: Container(
                                          width: 250,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12, /*horizontal: 30*/
                                          ),
                                          margin: EdgeInsets.only(
                                              left: 50, right: 50, bottom: 20),
                                          decoration: BoxDecoration(
                                            color: HexColor('ff6b6c'),
                                            border: Border.all(
                                                color: HexColor('ff6b6c'),
                                                width: 1),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                          ),
                                          child: Text(
                                            "Complete Challenge",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        onTap: () {}),
                              ],
                            )))
                  ],
                ),
              ),
            ]),
          );
  }

  void _showShare() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SharePost();
        });
  }
}
