import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/tutorial_screens/challenges_tutorials.dart';

class ChallengeHub extends StatefulWidget {
  @override
  _ChallengeHubState createState() => _ChallengeHubState();
}

class _ChallengeHubState extends State<ChallengeHub>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Challenge Someone'),
          centerTitle: true,
        ),
        body: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(
              height: 20,
            ),
            PrimaryFundderButton(
              text: 'Create challenge or competition',
              onPressed: () {
                Navigator.pushNamed(context, '/challengefriend');
              },
            ),
            SizedBox(
              height: 20,
            ),
            TabBar(
              tabs: [Tab(text: 'For me'), Tab(text: 'By me')],
              controller: _tabController,
            ),
            [
              FutureBuilder(
                  future: DatabaseService(uid: user.uid).getChallengesForMe(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      List<DocumentSnapshot> challengesList = snapshot.data;
                      if (challengesList.isEmpty == false) {
                        print('challenges list: ' + challengesList.toString());

                        return ChallengeHubTileView(
                          challengesToShow: challengesList,
                        );
                      } else {
                        return Center(
                            child: Container(
                                margin: EdgeInsets.all(40),
                                child: Text(
                                  'No challenges accepted. Accept a challenge from a friend for it to appear here. They will need to send you a link to the challenge.',
                                  textAlign: TextAlign.center,
                                )));
                      }
                    } else {
                      return Loading();
                    }
                  }),
              FutureBuilder(
                  future: DatabaseService(uid: user.uid).getChallengesByMe(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      List<DocumentSnapshot> challengesList = snapshot.data;
                      if (challengesList.isEmpty == false) {
                        print('challenges list: ' + challengesList.toString());

                        return ChallengeHubTileView(
                          challengesToShow: challengesList,
                        );
                      } else {
                        return Text(
                            'No challenges created. Create a challenge for it to appear here.');
                      }
                    } else {
                      return Loading();
                    }
                  }),
            ][_tabController.index]
          ],
        ));
  }
}

class ChallengeHubTileView extends StatelessWidget {
  final List<DocumentSnapshot> challengesToShow;
  ChallengeHubTileView({this.challengesToShow});

  @override
  Widget build(BuildContext context) {
    print('challenges list 2: ' + challengesToShow.toString());
    return ListView.builder(
        shrinkWrap: true,
        itemCount: challengesToShow.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          if (challengesToShow.isEmpty == true) {
            print('challenges to show is empty');
            return Text('No challenges created');
          } else {
            DocumentSnapshot snapshot = challengesToShow[i];
            print('challenge specific: ' + snapshot.toString());
            return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context, '/challenge/' + snapshot.documentID, arguments: {
                    'username': snapshot.data['authorUsername'],
                    'uid': snapshot.data['author']
                  });
                },
                child: Container(
                    color: Colors.white,
                    child: Column(children: [
                      Container(
                          height: 65,
                          margin: EdgeInsets.only(
                              left: 0, right: 0, top: 20, bottom: 0),
                          child: Row(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                    margin: EdgeInsets.only(
                                        left: 10, right: 15, top: 0, bottom: 0),
                                    child: AspectRatio(
                                      aspectRatio: 1 / 1,
                                      child: ClipRRect(
                                        borderRadius: new BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          bottomLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                          bottomRight: Radius.circular(10.0),
                                        ),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl:
                                              '${snapshot.data['imageUrl']}',
                                          placeholder: (context, url) =>
                                              Loading(),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: Colors.grey[100],
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Align(
                                          alignment: Alignment.topLeft,
                                          child: Row(children: [
                                            Expanded(
                                                child: Text(
                                              '${snapshot.data['title']}',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'Founders Grotesk',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            )),
                                          ])),
                                      Padding(padding: EdgeInsets.all(1.5)),
                                      Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                              margin:
                                                  EdgeInsets.only(right: 10),
                                              child: RichText(
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  text: TextSpan(
                                                    children: _returnHashtags(
                                                        snapshot
                                                            .data['hashtags'],
                                                        context,
                                                        snapshot
                                                            .data['subtitle']),
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  )))),
                                    ]),
                              ),
                            ],
                          )),
                      Container(
                          margin: EdgeInsets.only(left: 10, bottom: 15, top: 5),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    'Challenge by ${snapshot.data['authorUsername']}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context,
                                      '/charity/' + snapshot.data['charity']);
                                },
                                child: Container(
                                    constraints: BoxConstraints(maxWidth: 100),
                                    margin:
                                        EdgeInsets.only(left: 20, right: 10),
                                    height: 30,
                                    //color: Colors.blue,
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data['charityLogo'],
                                      //color: Colors.red,
                                    )),
                              )
                            ],
                          ))
                    ])));
          }
        });
  }

  List<TextSpan> _returnHashtags(
      List hashtags, BuildContext context, String templateText) {
    List<TextSpan> hashtagText = [
      TextSpan(
          text: templateText + " ",
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
              color: Colors.blueGrey[700],
              fontFamily: 'Founders Grotesk' /*HexColor('ff6b6c')*/,
              fontSize: 16,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(
                    context, '/hashtag/' + hashtags[i].toString());
              }));
      }
    }
    hashtagText.add(TextSpan(text: " "));
    return hashtagText;
  }
}
