import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'models/template.dart';
import 'package:fundder/services/database.dart';
import 'helper_classes.dart';
import 'global_widgets/buttons.dart';
import 'web_pages/web_menu.dart';
import 'shared/loading.dart';
import 'package:fundder/shared/helper_functions.dart';

class ChallengeDetail extends StatefulWidget {
  final String challengeId;
  ChallengeDetail({this.challengeId});

  _ChallengeDetailState createState() => _ChallengeDetailState();
}

class _ChallengeDetailState extends State<ChallengeDetail> {
  Future<Template> _getTemplate() async {
    Template template =
        await DatabaseService().getTemplateById(widget.challengeId);
    return template;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getTemplate(),
        builder: (BuildContext context, AsyncSnapshot<Template> snapshot) {
          if (snapshot.hasData) {
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
                          height: MediaQuery.of(context).size.width * 9 / 16,
                          child: kIsWeb == true
                              ? Image.network(snapshot.data.imageUrl)
                              : CachedNetworkImage(
                                  imageUrl: snapshot.data.imageUrl,
                                  placeholder: (context, url) => Loading(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
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
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 0),
                                    height: 30,
                                    child: Row(children: <Widget>[
                                      Expanded(
                                        child: Center(
                                            child: Text(
                                          "£${snapshot.data.amountRaised} raised",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        )),
                                      ),
                                      Expanded(
                                        child: Center(
                                            child: Text(
                                          "${snapshot.data.acceptedBy.length} participants",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        )),
                                      ),
                                      Expanded(
                                        child: Center(
                                            child: Text(
                                          "${howLongAgo(snapshot.data.timestamp)}",
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
                                        snapshot.data.title,
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
                                      child: Text(snapshot.data.subtitle)),
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
          } else {
            return Center(child: Container(child: Text('Loading...')));
          }
        });
  }
}
