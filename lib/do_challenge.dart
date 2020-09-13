import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fundder/helper_classes.dart';
import 'package:fundder/models/user.dart';

import 'package:fundder/services/database.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'models/template.dart';
import 'shared/loading.dart';
import 'tutorial_screens/tutorial_screen_controller.dart';
import 'package:provider/provider.dart';

class DoChallenge extends StatefulWidget {
  @override
  _DoChallengeState createState() => _DoChallengeState();

  final user;
  DoChallenge(this.user);
}

class _DoChallengeState extends State<DoChallenge> {
  List<Template> templates;

  bool checkedTutorial = false;
  int limit = 10;
  Timestamp loadingTimestamp;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<List<Template>> _getTemplates() async {
    loadingTimestamp = Timestamp.now();
    // print(widget.user.uid);
    List<Template> templateList =
        await DatabaseService().refreshTemplates(limit, loadingTimestamp);
    print("GOT NEW TEMPLATES:");
    print(templateList);
    Template t = templateList.last;
    loadingTimestamp = t.timestamp;
    templates = templateList;
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  Future<List<Template>> _loadTemplates() async {
    List<Template> templateList =
        await DatabaseService().refreshTemplates(limit, loadingTimestamp);
    print(templateList.length);
    if (templateList.length != 0) {
      Template t = templateList.last;
      loadingTimestamp = t.timestamp;
      return templateList;
    } else {
      return [];
    }
  }

  void _onLoading() async {
    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    List<Template> newTemplates = await _loadTemplates();
    print("GOT NEW TEMPLATES:");
    print(newTemplates);
    if (newTemplates != []) {
      templates = templates + newTemplates;
      if (mounted) setState(() {});
      _refreshController.loadComplete();
    } else {
      if (mounted) setState(() {});
      _refreshController.loadNoData();
    }
  }

  @override
  void initState() {
    super.initState();
    _getTemplates();
  }

  void checkTutorial(User firebaseUser) async {
    Firestore.instance
        .collection("users")
        .document(firebaseUser.uid)
        .get()
        .then((snapshot) {
      if (snapshot != null) {
        if (snapshot['fundTutorialSeen'] != null) {
          if (snapshot['fundTutorialSeen'] != true) {
            _showFundTutorial(context);
          }
        } else {
          _showFundTutorial(context);
        }
      }
    });
  }

  Future<void> _showFundTutorial(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return TutorialScreenController();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (checkedTutorial == false) {
      checkTutorial(user);
      checkedTutorial = true;
    }
    if (templates == null) {
      return Loading();
    } else {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: WaterDropHeader(),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text("Pull up to load");
              } else if (mode == LoadStatus.loading) {
                body = CupertinoActivityIndicator();
              } else if (mode == LoadStatus.failed) {
                body = Text("Load Failed! Click retry!");
              } else if (mode == LoadStatus.canLoading) {
                body = Text("Release to load more");
              } else {
                body = Text("No more data");
              }
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          controller: _refreshController,
          onRefresh: () async {
            _getTemplates();
          },
          onLoading: _onLoading,
          child: templates == null
              ? Container()
              : ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      color: Colors.grey,
                      height: 0,
                      thickness: 0.3,
                      indent: 20,
                      endIndent: 0,
                    );
                  },
                  itemBuilder: (c, i) => _templateListView(templates[i], i),
                  itemCount: templates.length,
                  padding: const EdgeInsets.only(top: 10.0),
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                ),
        ),
      );
    }
  }

  Widget _templateListView(Template template, int index) {
    return GestureDetector(
      child: Container(
          margin: EdgeInsets.only(left: 0, right: 0, top: 0),
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: index == 0
                ? BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  )
                : index == templates.length - 1
                    ? BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                      )
                    : BorderRadius.only(
                        bottomLeft: Radius.circular(0.0),
                        bottomRight: Radius.circular(0.0),
                      ),
          ),
          child: Container(
              margin: EdgeInsets.only(left: 0, right: 0, top: 0),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 65,
                    margin:
                        EdgeInsets.only(left: 0, right: 0, top: 20, bottom: 0),
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
                                  child: kIsWeb == true
                                      ? Image.network(template.imageUrl)
                                      : CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: '${template.imageUrl}',
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Row(children: [
                                      Expanded(
                                          child: Text(
                                        '${template.title}',
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
                                        margin: EdgeInsets.only(right: 10),
                                        child: RichText(
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            text: TextSpan(
                                              children: _returnHashtags(
                                                  template.hashtags,
                                                  context,
                                                  template.subtitle),
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            )))),
                              ]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 10, bottom: 15, top: 5),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                '${template.acceptedBy.length} people, ${template.daysLeft() != -1 ? template.daysLeft() : 0} days left',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/charity/' + template.charity);
                            },
                            child: Container(
                                constraints: BoxConstraints(maxWidth: 100),
                                margin: EdgeInsets.only(left: 20, right: 10),
                                height: 30,
                                //color: Colors.blue,
                                child: CachedNetworkImage(
                                  imageUrl: template.charityLogo,
                                  //color: Colors.red,
                                )),
                          )
                        ],
                      ))
                ],
              ))),
      onTap: () {
        getUsernameFromUID(widget.user.uid).then((username) => {
              Navigator.pushNamed(context, '/challenge/' + template.id,
                  arguments: {'username': username, 'uid': widget.user.uid})
            });
      },
    );
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
