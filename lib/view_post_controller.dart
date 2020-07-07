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

class ViewPost extends StatefulWidget {
  final String postData;
  ViewPost({this.postData});

  @override
  _ViewPostState createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  Post post;

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
    //print(widget.postData);
    _getPost();
    /*DatabaseService(uid: user.uid).getPostById(widget.postData)
                    .then((post) => {
                      setState(() {
                        post = post;
                      })
                    });*/
    super.initState();
  }

  void _getPost() async {
    Firestore.instance.document('posts/' + widget.postData).get().then((doc) {
      setState(() {
        if (doc != null) {
          post = Post(
            author: 'samsam',
            title: 'No Hands Turkey',
            charity: 'Cancer Research',
            amountRaised: '0',
            targetAmount: '100',
            likes: null,
            comments: [],
            subtitle:
                'I will film myself eating an entire Christmas turkey without using my hands',
            //timestamp: doc.data['timestamp'],
            imageUrl:
                'https://i.pinimg.com/originals/59/8c/60/598c60cf76ebd106784116ca040e558d.jpg',
            id: doc.documentID,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("View post controller");
    Post postData = post;
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
                                                    "assets/images/Sam_Luxa.png",
                                                    40),
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
                                Container(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.width *
                                        9 /
                                        16,
                                    child: CachedNetworkImage(
                                      imageUrl: (postData.imageUrl != null)
                                          ? postData.imageUrl
                                          : 'https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg',
                                      placeholder: (context, url) => Loading(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ), //Image.network('https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg'),
                                  ),
                                  margin: EdgeInsets.symmetric(vertical: 10.0),
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
                                            child: Image.asset(
                                                'assets/images/like.png'),
                                          ),
                                          Expanded(
                                              child: Container(
                                                  margin:
                                                      EdgeInsets.only(left: 10),
                                                  child: Text(
                                                    '0',
                                                    textAlign: TextAlign.left,
                                                  )))
                                        ]),
                                        onPressed: () {
                                          final snackBar =
                                              SnackBar(content: Text("Tap"));
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
                                                    '0'.toString(),
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
                                  child: Text('1 min ago',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      )),
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
                                    percent:
                                        double.parse(postData.amountRaised) /
                                            double.parse(postData.targetAmount),
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
