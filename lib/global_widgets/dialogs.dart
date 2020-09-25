import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DialogManager {
  Future<void> createDialog(
      String title, String subtitle, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return DialogWidget(
          subtitle: subtitle,
          title: title,
          actionsList: <Widget>[
            FlatButton(
              child: Text('OK', style: TextStyle(color: HexColor('ff6b6c'))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showChoiceDialog(String title, String subtitle,
      BuildContext context, List<Widget> actionsList) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return DialogWidget(
            subtitle: subtitle, title: title, actionsList: actionsList);
      },
    );
  }

  Future<void> showDeleteDialog(
      Post post, BuildContext context, VoidCallback onDeletePressed) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return DialogWidget(
          subtitle:
              'Once you delete this post, all the money donated will be refunded unless you have uploaded proof of challenge completion. This cannot be undone.',
          title: 'Delete Post?',
          actionsList: <Widget>[
            FlatButton(
              child:
                  Text('Delete', style: TextStyle(color: HexColor('ff6b6c'))),
              onPressed: () {
                Firestore.instance
                    .collection('posts')
                    .document(post.id)
                    .delete()
                    .then((value) {
                  Navigator.of(context).pop();
                  onDeletePressed();
                });
              },
            ),
            FlatButton(
              child:
                  Text('Cancel', style: TextStyle(color: HexColor('ff6b6c'))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class DialogWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actionsList;
  DialogWidget({this.title, this.subtitle, this.actionsList});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(title),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(subtitle),
            ],
          ),
        ),
        actions: this.actionsList);
  }
}
