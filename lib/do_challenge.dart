import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fundder/models/user.dart';

import 'package:fundder/services/database.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'models/template.dart';
import 'shared/loading.dart';

class DoChallenge extends StatefulWidget {
  @override
  _DoChallengeState createState() => _DoChallengeState();

  final user;
  DoChallenge(this.user);
}

class _DoChallengeState extends State<DoChallenge> {
  List<Template> templates;

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
      setState(() {});
      _refreshController.loadNoData();
    } else {
      templates = templates + newTemplates;
      if (mounted) setState(() {});
      _refreshController.loadComplete();
    }
  }

  @override
  void initState() {
    super.initState();
    _getTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  return SizedBox(
                    height: 10,
                  );
                },
                itemBuilder: (c, i) => _templateListView(templates[i]),
                itemCount: templates.length,
                padding: const EdgeInsets.only(top: 10.0),
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
              ),
      ),
    );
  }

  Widget _templateListView(Template template) {
    return GestureDetector(
      child: Container(
          color: Colors.white,
          child: Container(
              margin: EdgeInsets.only(left: 0, right: 0, top: 0),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 80,
                    margin: EdgeInsets.only(left: 0, right: 0, top: 0),
                    child: Row(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                              margin:
                                  EdgeInsets.only(left: 10, right: 10, top: 0),
                              child: AspectRatio(
                                aspectRatio: 1 / 1,
                                child: Container(
                                  child: kIsWeb == true
                                      ? Image.network(template.imageUrl)
                                      : CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: '${template.imageUrl}',
                                          placeholder: (context, url) =>
                                              Loading(),
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error),
                                        ),
                                ),
                              )),
                        ),
                        Expanded(
                          child: Column(children: [
                            Align(
                                alignment: Alignment.topLeft,
                                child: Row(children: [
                                  Expanded(
                                      child: Text(
                                    '${template.title}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Roboto Mono',
                                      fontSize: 16,
                                    ),
                                  )),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context,
                                            '/charity/' + template.charity);
                                      },
                                      child: Container(
                                          height: 20,
                                          //color: Colors.blue,
                                          margin: EdgeInsets.only(right: 10.0),
                                          child: CachedNetworkImage(
                                            imageUrl: template.charityLogo,
                                            //color: Colors.red,
                                          )))
                                ])),
                            Padding(padding: EdgeInsets.all(2)),
                            Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '${template.subtitle}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                )),
                            Expanded(
                                child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Row(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                            '${template.acceptedBy.length} people, ${template.daysLeft() != -1 ? template.daysLeft() : 0} days left',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )))
                          ]),
                        ),
                      ],
                    ),
                  ),
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
}
