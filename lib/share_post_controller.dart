import 'package:flutter/material.dart';

class SharePostScreen extends StatefulWidget {
  @override
  _SharePostState createState() => _SharePostState();
}

class _SharePostState extends State<SharePostScreen> {

  final List<String> whoDoes = <String>["A specific person",'Myself','Anyone'];
  final List<String> charities = <String>["Cancer Research",'British Heart Foundation','Oxfam'];
  int selected = -1;
  int charity = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Share Post"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close), 
            onPressed: () => Navigator.of(context).pop(null),
            )
        ],
        leading: new Container(),
      ),
      body:
        ListView(
          children: <Widget>[
            Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: <Widget>[
                  Text('This is where we share posts. Appears after post submission or on press of share button',style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),),
                ])
            ), 
          ], 
          ),
    );
  }
}