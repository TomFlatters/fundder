import 'package:flutter/material.dart';
import 'package:fundder/models/template.dart';

class StepsPage extends StatefulWidget {
  final Template template;
  final String challengeId;
  StepsPage({this.template, this.challengeId});
  _StepsPageState createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> {
  @override
  Widget build(BuildContext context) {
    Template template;
    final Map arguments = ModalRoute.of(context).settings.arguments as Map;
    if (arguments != null) {
      template = arguments['template'];
    }

    return (template == null)
        ? null
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(template.title),
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
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Challenge description: ${template.subtitle}',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            'This challenge is raising money for ${template.charity}.',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            'This is where people will see the steps to do challenge. Then after they complete it, it will generate a post which the user can edit.',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ])),
              ],
            ),
          );
  }
}
