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

  final List<String> charities = <String>['Cancer Research', 'Cancer Research'];
  final List<String> users = <String>['samsam', 'dk_david'];
  final List<String> descriptions = <String>[
    'I will film myself eating an entire Christmas turkey without using my hands',
    '£50 and I will live as a mountain goat this Saturday (24hrs)'
  ];
  final List<String> images = <String>[
    'https://i.pinimg.com/originals/59/8c/60/598c60cf76ebd106784116ca040e558d.jpg',
    'https://i.pinimg.com/originals/72/8f/6e/728f6e7683ca126c324fead153e7d115.jpg'
  ];
  final List<String> profilePics = <String>[
    'assets/images/Sam_Luxa.png',
    'assets/images/David_Kim.jpg'
  ];
  final List<double> amountRaised = <double>[0, 65.78];
  final List<double> amountAimed = <double>[100, 100];
  final List<int> likes = <int>[0, 135];
  final List<int> comments = <int>[0, 11];

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
              itemCount: 2,
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
                                                    profilePics[index], 40),
                                                margin: EdgeInsets.all(10.0),
                                              )),
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/username');
                                          },
                                        )),
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(users[index]
                                            /*style: TextStyle(
                                    fontFamily: 'Roboto Mono'
                                  ),*/
                                            )),
                                    Expanded(
                                        child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                                margin: EdgeInsets.all(10.0),
                                                child:
                                                    Text(charities[index])))),
                                  ],
                                ),
                              ),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.all(10),
                                  child: Text(descriptions[index])),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  child: Text(
                                    '£${amountRaised[index]} raised of £${amountAimed[index]} target',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(
                                    top: 5, bottom: 15, left: 0, right: 0),
                                child: LinearPercentIndicator(
                                  linearStrokeCap: LinearStrokeCap.butt,
                                  lineHeight: 3,
                                  percent:
                                      amountRaised[index] / amountAimed[index],
                                  backgroundColor: HexColor('CCCCCC'),
                                  progressColor: HexColor('ff6b6c'),
                                ),
                              ),
                              Container(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width *
                                      9 /
                                      16,
                                  child: CachedNetworkImage(
                                    imageUrl: (postData.imageUrl != null)
                                        ? images[index]
                                        : 'https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg',
                                    placeholder: (context, url) => Loading(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                                margin: EdgeInsets.symmetric(vertical: 10.0),
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
                                          child: Image.asset(
                                              'assets/images/like.png'),
                                        ),
                                        Expanded(
                                            child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  likes[index].toString(),
                                                  textAlign: TextAlign.left,
                                                )))
                                      ]),
                                      onPressed: () {
                                        final snackBar = SnackBar(
                                            content: Text("Like passed"));
                                        Scaffold.of(context)
                                            .showSnackBar(snackBar);
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
                                                  comments[index].toString(),
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
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.all(10),
                                child: Text('1 min ago',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    )),
                              )
                            ],
                          ))),
                  onTap: () {
                    print(postData);
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
