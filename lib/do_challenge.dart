import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:fundder/services/database.dart';
import 'models/template.dart';
import 'shared/loading.dart';

class DoChallenge extends StatefulWidget {
  @override
  _DoChallengeState createState() => _DoChallengeState();
}

class _DoChallengeState extends State<DoChallenge> {
  Future<List<Template>> _getTemplates() async {
    List<Template> templateList = await DatabaseService().getTemplates();
    return templateList;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Template>>(
        future: _getTemplates(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Template>> snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 10.0),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return _templateListView(snapshot.data[index]);
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 10,
                );
              },
            );
          } else {
            return Center(child: Container(child: Text('Loading...')));
          }
        });
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
                                  EdgeInsets.only(left: 20, right: 20, top: 0),
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
                                child: Text(
                                  '${template.title}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Roboto Mono',
                                    fontSize: 16,
                                  ),
                                )),
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
        Navigator.pushNamed(context, '/challenge/' + template.id);
      },
    );
  }
}
