import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:fundder/services/database.dart';
import 'package:provider/provider.dart';

import 'package:fundder/models/post.dart';
import 'package:fundder/models/template.dart';
import 'package:fundder/models/user.dart';
import 'global_widgets/buttons.dart';

class StepsPage extends StatefulWidget {
  final Template template;
  final String challengeId;
  StepsPage({this.template, this.challengeId});
  _StepsPageState createState() => _StepsPageState();
}

class _StepsPageState extends State<StepsPage> {
  final moneyController =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

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
              title: Text('Do a Challenge'),
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
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 0),
                            child: Text(
                              template.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 0),
                            child: Text(
                              template.subtitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 0),
                            child: Text(
                              'Raising money for ${template.charity}',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Set your fundraising target:',
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Row(children: [
                                      Text(
                                        '£',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w100,
                                          fontFamily: 'Roboto Mono',
                                          fontSize: 45,
                                        ),
                                      ),
                                      Expanded(
                                          child: TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w100,
                                                fontFamily: 'Roboto Mono',
                                                fontSize: 45,
                                              ),
                                              controller: moneyController,
                                              decoration: InputDecoration(
                                                  hintText: 'Amount in £'))),
                                    ])
                                  ])),
                          PrimaryFundderButton(
                              text: 'Accept Challenge',
                              onPressed: () {
                                _makePostFromTemplate(template, user,
                                    moneyController.text.toString());
                              }),
                        ])),
              ],
            ),
          );
  }

  void _makePostFromTemplate(Template template, User user, String amount) {
    // Get username
    String fetchedUsername;
    DatabaseService(uid: user.uid)
        .readUserData()
        .then((fetchedUser) => {fetchedUsername = fetchedUser.username})
        .then((_) =>
            _uploadPostFromTemplate(template, user, amount, fetchedUsername));
  }

  void _uploadPostFromTemplate(
      Template template, User user, String amount, String fetchedUsername) {
    // Upload post
    DatabaseService(uid: user.uid)
        .uploadPost(new Post(
          title: template.title,
          subtitle: template.subtitle,
          author: user.uid,
          authorUsername: fetchedUsername,
          charity: template.charity,
          noLikes: 0,
          comments: [],
          timestamp: DateTime.now(),
          amountRaised: "0",
          targetAmount: amount,
          imageUrl: template.imageUrl,
          status: 'fund',
          templateTag: template.id,
        ))
        // Reroute to new post page
        .then((postId) => {
              Navigator.pushReplacementNamed(
                  context,
                  '/post/' +
                      postId
                          .toString()
                          .substring(1, postId.toString().length - 1))
            });
  }
}
