import 'package:flutter/material.dart';
import 'helper_classes.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'share_post_view.dart';
import 'donate_page_controller.dart';
import 'comment_view_controller.dart';
import 'challenge_steps_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shared/loading.dart';

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
      appBar: AppBar(
        centerTitle: true,
        title: Text("Post Title"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(null),
          )
        ],
        leading: new Container(),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 9 / 16,
              child: CachedNetworkImage(
                imageUrl:
                    "https://images.jg-cdn.com/image/b410179a-2042-4c6b-903b-df106b48fc3c.jpg",
                placeholder: (context, url) => Loading(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ), //Image.network('https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg'),
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
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        height: 30,
                        child: Row(children: <Widget>[
                          Expanded(
                            child: Center(
                                child: Text(
                              "£45,000 raised",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            )),
                          ),
                          Expanded(
                            child: Center(
                                child: Text(
                              "457 participants",
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
                            'Do a challenge for cancer research',
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
                              'This is a longer description of whatever the fuck they are doing')),
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
                                left: 50, right: 50, bottom: 10),
                            decoration: BoxDecoration(
                              color: HexColor('ff6b6c'),
                              border: Border.all(
                                  color: HexColor('ff6b6c'), width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Text(
                              "Join Now",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context,
                                '/challenge/' + widget.challengeId + '/steps');
                          }),
                      GestureDetector(
                          child: Container(
                            width: 250,
                            padding: EdgeInsets.symmetric(
                              vertical: 12, /*horizontal: 30*/
                            ),
                            margin: EdgeInsets.only(
                                left: 50, right: 50, bottom: 20),
                            decoration: BoxDecoration(
                              //color: HexColor('ff6b6c'),
                              border: Border.all(
                                  color: HexColor('ff6b6c'), width: 2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Text(
                              "View Completed",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: HexColor('ff6b6c'),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context,
                                '/challenge/' + widget.challengeId + '/steps');
                          }),
                    ],
                  )))
        ],
      ),
    );
  }
}
