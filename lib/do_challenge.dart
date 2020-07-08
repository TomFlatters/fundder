import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'share_post_view.dart';
import 'helper_classes.dart';
import 'comment_view_controller.dart';
import 'other_user_profile.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'do_challenge_detail.dart';
import 'shared/loading.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shared/loading.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DoChallenge extends StatefulWidget {
  @override
  _DoChallengeState createState() => _DoChallengeState();
}

class _DoChallengeState extends State<DoChallenge> {
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

    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 10.0),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                entries[index],
                textAlign: TextAlign.left,
              ),
            ),
            _sectionComponents(
                entries2[index], entries3[index], entries4[index])
          ],
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 10,
        );
      },
    );
  }

  Widget _sectionComponents(List array, List array2, List array3) {
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
