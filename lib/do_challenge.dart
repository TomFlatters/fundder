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
  Widget build(BuildContext context) {
    final List<String> entries = <String>['Active', 'Past'];
    final List<String> active = ['Sleep 2 nights in the garden'];
    final List<String> activeDescription = [
      'Sleep 2 nights in the garden to raise money for Help Refugees'
    ];
    final List<String> activePics = [
      'https://i.pinimg.com/originals/99/d9/fa/99d9fa7c22ca5ca5856cf4dd30db692e.jpg'
    ];

    final List<String> past = [
      'Run 5, Donate £5, Nominate 5',
      'ALS Ice Bucket'
    ];
    final List<String> pastDescriptions = [
      'Run 5k, donate £5 to Run for Heroes and nominate 5 people to do the same',
      'Throw ice on yourself to raise money for ALS'
    ];
    final List<String> pastPics = [
      'https://blog.theclymb.com/wp-content/uploads/2014/03/pinterest-quotes-for-running-featured.jpg',
      'https://api.time.com/wp-content/uploads/2014/08/ice-bucket-challenge2.jpg'
    ];
    final List<List> entries2 = <List>[active, past];
    final List<List> entries3 = <List>[activeDescription, pastDescriptions];
    final List<List> entries4 = <List>[activePics, pastPics];

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
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 10.0),
      itemCount: array.length,
      itemBuilder: (BuildContext context, int index) {
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
                                  margin: EdgeInsets.only(
                                      left: 20, right: 20, top: 0),
                                  child: AspectRatio(
                                    aspectRatio: 1 / 1,
                                    child: Container(
                                      child: kIsWeb == true
                                          ? Image.network(array3[index])
                                          : CachedNetworkImage(
                                              imageUrl: '${array3[index]}',
                                              placeholder: (context, url) =>
                                                  Loading(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ), //Image.network('https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg'),
                                    ),
                                  )),
                            ),
                            Expanded(
                              child: Column(children: [
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      '${array[index]}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Roboto Mono',
                                        fontSize: 16,
                                        //fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                Padding(padding: EdgeInsets.all(2)),
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      '${array2[index]}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        //fontWeight: FontWeight.bold,
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
                                                '${index * 4000 - 345 + 87 * 98} people, 16 days left',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                  //fontWeight: FontWeight.bold,
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
            Navigator.pushNamed(context, '/challenge/' + '123');
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 20,
        );
      },
    );
  }
}
