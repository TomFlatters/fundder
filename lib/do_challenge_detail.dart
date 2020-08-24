import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fundder/profile_controller.dart';

import 'models/template.dart';
import 'package:fundder/services/database.dart';
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
    bool hasAccepted = false;
    String username = '';
    String uid = '';
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    if (arguments != null) {
      username = arguments['username'].toString();
      uid = arguments['uid'].toString();
    }

    return FutureBuilder(
        future: _getTemplate(),
        builder: (BuildContext context, AsyncSnapshot<Template> snapshot) {
          if (snapshot.hasData) {
            print('Username: ' + username);
            if (snapshot.data.acceptedBy.contains(username.toString())) {
              hasAccepted = true;
            }
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
                                  imageUrl: snapshot.data.imageUrl != null
                                      ? snapshot.data.imageUrl
                                      : "",
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
                                      child: Row(children: [
                                        Expanded(
                                            child: Text(
                                          snapshot.data.title,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Roboto Mono',
                                            fontSize: 16,
                                          ),
                                        )),
                                        Container(
                                            margin: EdgeInsets.only(right: 10),
                                            height: 20,
                                            child: CachedNetworkImage(
                                                imageUrl:
                                                    snapshot.data.charityLogo)),
                                      ])),
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: Text(snapshot.data.subtitle)),
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: Text(
                                          'A challenge by ${snapshot.data.charity}')),
                                  Padding(
                                    padding: EdgeInsets.all(20),
                                  ),
                                  PrimaryFundderButton(
                                      text: hasAccepted
                                          ? 'Your Post'
                                          : 'Join Now',
                                      onPressed: () {
                                        if (hasAccepted) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileController(
                                                          uid: uid)));
                                        } else {
                                          Navigator.pushNamed(
                                              context,
                                              '/challenge/' +
                                                  widget.challengeId +
                                                  '/steps',
                                              arguments: {
                                                'template': snapshot.data
                                              });
                                        }
                                      }),
                                  /*SecondaryFundderButton(
                                      text: 'View Completed',
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context,
                                            '/challenge/' +
                                                widget.challengeId +
                                                '/steps');
                                      }),*/
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
  }
}
