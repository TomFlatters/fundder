import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'helper_classes.dart';

class StepsPage extends StatefulWidget {
  @override
  _StepsPageState createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> {

  final List<String> whoDoes = <String>["A specific person",'Myself','Anyone'];
  final List<String> charities = <String>["Cancer Research",'British Heart Foundation','Oxfam'];
  int selected = -1;
  int charity = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Challenge Step"),
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
                  Text('This is where people will see the steps to do challenge. Then after they complete it, it will generate a post which the user can edit.',style: TextStyle(
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