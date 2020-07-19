import 'package:flutter/material.dart';
import 'package:fundder/models/template.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'helper_classes.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'share_post_view.dart';
import 'donate_page_controller.dart';
import 'comment_view_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/database.dart';

class ViewTemplate extends StatefulWidget {
  final String templateData;
  ViewTemplate({this.templateData});

  @override
  _ViewTemplateState createState() => _ViewTemplateState();
}

class _ViewTemplateState extends State<ViewTemplate> {
  Template template;

  @override
  void initState() {
    _getTemplate();
    super.initState();
  }

  void _getTemplate() async {
    DatabaseService().getTemplateById(widget.templateData.toString()).then((t) {
      print('template');
      print(t);
      setState(() {
        template = t;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("View template controller");
    Template templateData = template;
    return (templateData == null)
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(templateData.title),
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
                    color: Colors.white,
                    child: Container(
                        margin: EdgeInsets.symmetric(vertical: 10.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              height: 60,
                              child: Row(
                                children: <Widget>[
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: AspectRatio(
                                          aspectRatio: 1 / 1,
                                          child: Container(
                                            child: ProfilePic(
                                                "https://i.imgur.com/BoN9kdC.png",
                                                40),
                                            margin: EdgeInsets.all(10.0),
                                          ))),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        templateData.author,
                                        style: TextStyle(
                                          fontFamily: 'Quicksand',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )),
                                  Expanded(
                                      child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                              margin: EdgeInsets.all(10.0),
                                              child:
                                                  Text(templateData.charity)))),
                                ],
                              ),
                            ),
                            Container(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.width * 9 / 16,
                                child: CachedNetworkImage(
                                  imageUrl: (templateData.imageUrl != null)
                                      ? templateData.imageUrl
                                      : 'https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg',
                                  placeholder: (context, url) => Loading(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ), //Image.network('https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg'),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 0),
                              height: 30,
                              child: Row(children: <Widget>[
                                Expanded(
                                  child: FlatButton(
                                    child: Row(children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        padding: const EdgeInsets.all(0.0),
                                        child: Image.asset(
                                            'assets/images/like.png'),
                                      ),
                                      Expanded(
                                          child: Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Text(
                                                templateData.likes.length
                                                    .toString(),
                                                textAlign: TextAlign.left,
                                              )))
                                    ]),
                                    onPressed: () {
                                      final snackBar =
                                          SnackBar(content: Text("Tap"));
                                      Scaffold.of(context)
                                          .showSnackBar(snackBar);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: FlatButton(
                                    child: Row(children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        padding: const EdgeInsets.all(0.0),
                                        child: Image.asset(
                                            'assets/images/comment.png'),
                                      ),
                                      Expanded(
                                          child: Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Text(
                                                templateData.comments.length
                                                    .toString(),
                                                textAlign: TextAlign.left,
                                              )))
                                    ]),
                                    onPressed: () {
                                      /*Navigator.of(context)
                                    .push(_showComments());*/
                                      Navigator.pushNamed(
                                          context,
                                          '/post/' +
                                              widget.templateData +
                                              '/comments');
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: FlatButton(
                                    child: Row(children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        padding: const EdgeInsets.all(0.0),
                                        child: Image.asset(
                                            'assets/images/share.png'),
                                      ),
                                      Expanded(
                                          child: Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: Text(
                                                'Share',
                                                textAlign: TextAlign.left,
                                              )))
                                    ]),
                                    onPressed: () {
                                      _showShare();
                                    },
                                  ),
                                )
                              ]),
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              child: Text(howLongAgo(templateData.timestamp),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  )),
                            ),
                            Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Text(
                                  '£${templateData.amountRaised} raised of £${templateData.targetAmount} target',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(
                                  top: 5, bottom: 15, left: 10, right: 10),
                              child: LinearPercentIndicator(
                                linearStrokeCap: LinearStrokeCap.butt,
                                lineHeight: 3,
                                percent: templateData.percentRaised(),
                                backgroundColor: HexColor('CCCCCC'),
                                progressColor: HexColor('ff6b6c'),
                              ),
                            ),
                            Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: Text(templateData.subtitle)),
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
                                      left: 50, right: 50, bottom: 20),
                                  decoration: BoxDecoration(
                                    color: HexColor('ff6b6c'),
                                    border: Border.all(
                                        color: HexColor('ff6b6c'), width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: Text(
                                    "Donate",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  /*Navigator.of(context).push(_openDonate());*/
                                  Navigator.pushNamed(
                                      context,
                                      '/post/' +
                                          widget.templateData +
                                          '/donate');
                                }),
                          ],
                        )))
              ],
            ),
          );
  }

  void _showShare() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SharePost();
        });
  }
}
