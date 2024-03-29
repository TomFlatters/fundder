//will house the post title, desciption and media if there's any media, along
// with how much money has been raised so far

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/models/post.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'package:fundder/shared/loading.dart';
import 'package:fundder/video_item.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:fundder/models/user.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PostBody extends StatelessWidget {
  final Post postData;
  final String hashtag;
  final int maxLines;
  PostBody(
      {this.postData,
      this.hashtag,
      this.maxLines,
      @required this.likesManager});
  StreamController<void> likesManager;
  CarouselController _carouselController = CarouselController();
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    return Column(
      children: <Widget>[
        (postData.imageUrl == null)
            ? Container()
            : CarouselSlider(
                items: _progressImages(context),
                carouselController: _carouselController,
                options: CarouselOptions(
                    enableInfiniteScroll: false,
                    aspectRatio: postData.aspectRatio,
                    viewportFraction: 1),
              ),
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.all(10),
            child: Text(postData.title + ' for ' + postData.charity,
                style: TextStyle(
                  fontWeight: FontWeight.bold, /*fontSize: 18*/
                ))),
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10),
            child: RichText(
                maxLines: this.maxLines,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    children:
                        _returnHashtags(postData.hashtags, context, user)))),
        (postData.completionComment == null ||
                postData.completionComment == '' ||
                this.maxLines == 2
            ? Container()
            : Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Text('Completion comment:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500, /*fontSize: 18*/
                    )))),
        postData.completionComment == null ||
                postData.completionComment == '' ||
                this.maxLines == 2
            ? Container()
            : Container(
                alignment: Alignment.centerLeft,
                margin:
                    EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10),
                child: Text(postData.completionComment,
                    style: TextStyle(
                      fontWeight: FontWeight.normal, /*fontSize: 18*/
                    ))),
        (postData.moneyRaised != null)
            ? (postData.moneyRaised > 0)
                ? Container(
                    margin: EdgeInsets.only(
                        top: 10, bottom: 10, left: 10, right: 10),
                    height: 25,
                    child: _peopleWhoDonatedIconRow(postData.id),
                  )
                : Container()
            : Container(),
        Container(
          //alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(top: 10, bottom: 10, left: 0, right: 0),
          child: LinearPercentIndicator(
            linearStrokeCap: LinearStrokeCap.roundAll,
            lineHeight: 5,
            percent: postData.percentRaised(),
            backgroundColor: HexColor('CCCCCC'),
            progressColor: HexColor('ff6b6c'),
          ),
        ),
        Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(bottom: 10, top: 0, left: 10, right: 10),
            child: Text(
              postData.targetAmount != '-1'
                  ? '£${postData.moneyRaised == null ? 0.00.toStringAsFixed(2) : postData.moneyRaised.toStringAsFixed(2)} raised of £${postData.targetAmount} target'
                  : '£0.00 raised of user-selected target',
              style: TextStyle(fontWeight: FontWeight.w500),
            )),
      ],
    );
  }

  List<Widget> _progressImages(BuildContext context) {
    List<Widget> images = [
      Stack(children: <Widget>[
        Container(
          child: postData.aspectRatio == null
              ? SizedBox(child: _previewImageVideo(postData))
              : SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height:
                      MediaQuery.of(context).size.width / postData.aspectRatio,
                  child: _previewImageVideo(postData)),
          margin: EdgeInsets.only(bottom: 10.0),
        ),
        postData.postProgress != null
            ? Container(
                alignment: Alignment.bottomRight,
                child: Row(
                    children: ([
                  Expanded(
                      child: Container(
                    height: 0,
                  )),
                  DecoratedBox(
                      decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(5)),
                          color: Color.fromRGBO(255, 255, 255, 0.7)),
                      child: Container(
                          padding: EdgeInsets.only(
                              right: 5, bottom: 15, left: 10, top: 5),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(MaterialCommunityIcons
                                    .gesture_swipe_horizontal),
                                SizedBox(width: 3),
                                Text('for progress',
                                    style: TextStyle(fontSize: 12)),
                              ])))
                ])))
            : Container(),
      ])
    ];
    List<Widget> imagesTemp = [];
    if (postData.postProgress != null) {
      print('retrieving post progress');

      for (Map item in postData.postProgress) {
        print('timestamp: ' + item['timestamp'].toString());
        Timestamp progressTimestamp;
        if (item['timestamp'] is Timestamp) {
          progressTimestamp = item['timestamp'];
        } else {
          int timeStampSecs = item['timestamp']['_seconds'];
          int timeStampNanoSecs = item['timestamp']['_nanoseconds'];
          progressTimestamp = Timestamp(timeStampSecs, timeStampNanoSecs);
        }
        imagesTemp.add(Stack(children: <Widget>[
          Container(
            child: item['aspectRatio'] == null
                ? SizedBox(
                    child: _previewImageVideo(Post(
                        imageUrl: item['imageUrl'],
                        timestamp: item['timestamp'],
                        videoThumbnail: item['video_thumbnail'],
                        aspectRatio: item['aspectRatio'] != null
                            ? item['aspectRatio'].toDouble()
                            : null,
                        isPrivate: false)))
                : SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width /
                        postData.aspectRatio,
                    child: _previewImageVideo(Post(
                        imageUrl: item['imageUrl'],
                        timestamp: item['timestamp'],
                        videoThumbnail: item['video_thumbnail'],
                        aspectRatio: item['aspectRatio'] != null
                            ? item['aspectRatio'].toDouble()
                            : null,
                        isPrivate: false))),
            margin: EdgeInsets.only(bottom: 10.0),
          ),
          Container(
              alignment: Alignment.bottomRight,
              child: DecoratedBox(
                  decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(5)),
                      color: Color.fromRGBO(255, 255, 255, 0.7)),
                  child: Container(
                    padding:
                        EdgeInsets.only(right: 5, bottom: 15, left: 10, top: 5),
                    child: Text(howLongAgo(progressTimestamp),
                        style: TextStyle(fontSize: 12)),
                  )))
        ]));
      }
    } else {
      print('no post progress found');
    }
    images = images + imagesTemp.reversed.toList();
    return images;
  }

  List<TextSpan> _returnHashtags(
      List hashtags, BuildContext context, User user) {
    List<TextSpan> hashtagText = [
      TextSpan(
          text: postData.subtitle + " ",
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Founders Grotesk',
              fontSize: 16))
    ];
    if (hashtags != null) {
      for (var i = 0; i < hashtags.length; i++) {
        hashtagText.add(TextSpan(
            text: "#" + hashtags[i].toString() + " ",
            style: TextStyle(
                color: Colors.blueGrey[700] /*HexColor('ff6b6c')*/,
                fontFamily: 'Founders Grotesk',
                fontSize: 16),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (user != null) {
                  if (hashtags[i].toString() != hashtag) {
                    _openFeed(context, hashtags[i]);
                  }
                }
              }));
      }
    }
    return hashtagText;
  }

  void _openFeed(BuildContext context, String hashtag) async {
    await Navigator.pushNamed(context, '/hashtag/' + hashtag.toString());
    this.likesManager.add(1);
  }

  Widget _previewImageVideo(Post postData) {
    if (postData.imageUrl.contains('video')) {
      print('initialising video');
      return VideoItem(
        key: UniqueKey(),
        url: postData.imageUrl,
        aspectRatio: postData.aspectRatio,
        videoThumbnail: postData.videoThumbnail,
      );
    } else {
      return kIsWeb == true
          ? Image.network(postData.imageUrl)
          : CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: (postData.imageUrl != null) ? postData.imageUrl : '',
              placeholder: (context, url) => Loading(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            );
    }
  }
}

_peopleWhoDonatedIconRow(postId) {
  return FutureBuilder(
    future: Firestore.instance
        .collection('postsV2')
        .document(postId)
        .collection('whoDonated')
        .getDocuments(),
    builder: (context, AsyncSnapshot snapshot) {
      if (snapshot.hasData) {
        QuerySnapshot query = snapshot.data;
        List<DocumentSnapshot> docs = query.documents;
        if (docs.length > 0) {
          var ids = docs.map((qDocSnap) => qDocSnap.documentID).toList();
          print(ids.toString());
          return GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      var height = MediaQuery.of(context).size.height;
                      return Container(
                        height: 0.6 * height,
                        color: Color(0xFF737373),
                        child: Container(
                          child: Scaffold(
                            body: _donorList(ids),
                            appBar: AppBar(
                              centerTitle: true,
                              title: Text('Donors'),
                              actions: <Widget>[
                                new IconButton(
                                  icon: new Icon(Icons.close),
                                  onPressed: () =>
                                      Navigator.of(context).pop(null),
                                )
                              ],
                              leading: new Container(),
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).canvasColor,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(10),
                              topRight: const Radius.circular(10),
                            ),
                          ),
                        ),
                      );
                    });
              },
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int index) {
                    var uid = ids[index];
                    return AspectRatio(
                      child: ProfilePic(uid, 20),
                      aspectRatio: 1,
                    );
                  },
                  separatorBuilder: (context, i) => SizedBox(
                        width: 10,
                      ),
                  itemCount: ids.length));
        } else {
          return Container();
        }
      } else {
        return Container();
      }
    },
  );
}

Future _getUsers(List uids) async {
  print("getting users for making donor page");
  CollectionReference usersCollection = Firestore.instance.collection('users');
  List userDocs = await Future.wait(
      uids.map((uid) => usersCollection.document(uid as String).get()));
  return userDocs.toList();
}

_donorList(List uids) {
  return Container(
    child: FutureBuilder(
        future: _getUsers(uids),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List docsSnaps = snapshot.data;
            return ListView.builder(
                itemCount: uids.length,
                itemBuilder: (BuildContext context, int index) {
                  var docSnap = docsSnaps[index];
                  if (docSnap.exists) {
                    var uid = docSnap.documentID;
                    var username = docSnap['username'];
                    return ListTile(
                      leading: ProfilePic(uid, 40),
                      title: Text(username != null ? username : 'anonymous'),
                      onTap: () => Navigator.pushNamed(context, '/user/' + uid),
                    );
                  } else {
                    return Container();
                  }
                });
          } else {
            return Container(
              child: Center(
                child: Loading(),
              ),
            );
          }
        }),
  );
}
