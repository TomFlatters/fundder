import 'package:flutter/material.dart';
import 'helper_classes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shared/loading.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_pages/web_menu.dart';
import 'global_widgets/buttons.dart';

class ChallengeDetail extends StatefulWidget {
  @override
  final String challengeId;
  ChallengeDetail({this.challengeId});

  _ChallengeDetailState createState() => _ChallengeDetailState();
}

class _ChallengeDetailState extends State<ChallengeDetail> {
  final List<String> whoDoes = <String>[
    "A specific person",
    'Myself',
    'Anyone'
  ];
  final List<String> charities = <String>[
    "Cancer Research",
    'British Heart Foundation',
    'Oxfam'
  ];
  int selected = -1;
  int charity = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb == true
          ? null
          : AppBar(
              centerTitle: true,
              title: Text("Do a challenge"),
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
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: kIsWeb == true
                      ? Image.network(
                          'https://i.pinimg.com/originals/99/d9/fa/99d9fa7c22ca5ca5856cf4dd30db692e.jpg')
                      : CachedNetworkImage(
                          imageUrl:
                              'https://i.pinimg.com/originals/99/d9/fa/99d9fa7c22ca5ca5856cf4dd30db692e.jpg',
                          placeholder: (context, url) => Loading(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                ),
                margin: EdgeInsets.symmetric(vertical: 10.0),
              ),
              Container(
                  color: Colors.white,
                  child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            height: 30,
                            child: Row(children: <Widget>[
                              Expanded(
                                child: Center(
                                    child: Text(
                                  "£450,000 raised",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                )),
                              ),
                              Expanded(
                                child: Center(
                                    child: Text(
                                  "8181 participants",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                )),
                              ),
                              Expanded(
                                child: Center(
                                    child: Text(
                                  "17 days left",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                )),
                              ),
                            ]),
                          ),
                          Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Text(
                                'Sleep 2 nights in the garden',
                                style: TextStyle(
                                  fontFamily: 'Roboto Mono',
                                  fontSize: 16,
                                  //fontWeight: FontWeight.bold,
                                ),
                              )),
                          Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Text(
                                  'Sleep 4 nights in the garden to raise money for Help Refugees')),
                          Padding(
                            padding: EdgeInsets.all(20),
                          ),
                          PrimaryFundderButton(
                              text: 'Join Now',
                              onPressed: () {
                                Navigator.pushNamed(
                                    context,
                                    '/challenge/' +
                                        widget.challengeId +
                                        '/steps');
                              }),
                          SecondaryFundderButton(
                              text: 'View Completed',
                              onPressed: () {
                                Navigator.pushNamed(
                                    context,
                                    '/challenge/' +
                                        widget.challengeId +
                                        '/steps');
                              }),
                        ],
                      )))
            ],
          ),
        ),
      ]),
    );
  }
}
