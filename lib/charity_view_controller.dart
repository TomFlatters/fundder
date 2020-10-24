import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'models/charity.dart';
import 'package:fundder/services/database.dart';
import 'shared/loading.dart';
import 'package:fundder/shared/helper_functions.dart';

class CharityView extends StatefulWidget {
  final String charityId;
  CharityView({this.charityId});

  _CharityViewState createState() => _CharityViewState();
}

class _CharityViewState extends State<CharityView> {
  Future<Charity> _getTemplate() async {
    Charity charity =
        await DatabaseService().readCharitiesData(widget.charityId);
    return charity;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getTemplate(),
        builder: (BuildContext context, AsyncSnapshot<Charity> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: null,
                actions: <Widget>[
                  new IconButton(
                    icon: new Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(null),
                  )
                ],
                leading: new Container(),
              ),
              body: Column(children: [
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Container(
                        height: 60,
                        child: CachedNetworkImage(
                          imageUrl: snapshot.data.image != null
                              ? snapshot.data.image
                              : "",
                          placeholder: (context, url) => Loading(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
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
                                      alignment: Alignment.topLeft,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: Row(children: [
                                        Expanded(
                                            child: Text(
                                          snapshot.data.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontFamily: 'Founders Grotesk',
                                              fontWeight: FontWeight.bold),
                                        )),
                                      ])),
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: Text(snapshot.data.bio)),
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
