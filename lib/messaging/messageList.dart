import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/messaging/individualMessage.dart';
import 'package:fundder/models/user.dart';
import 'package:provider/provider.dart';

/**
 * MessagesListWidget takes a list of messages and creates a ListBiew using the
 * ListView.builder() constructor, passing the data  needed to show the message 
 * to a Message widget
 */

class MessagesList extends StatelessWidget {
  MessagesList(this.data);
  final QuerySnapshot data;

  bool areSameDay(Timestamp a, Timestamp b) {
    var date1 = a.toDate().toLocal();
    var date2 = b.toDate().toLocal();
    return (date1.year == date2.year) &&
        (date1.month == date2.month) &&
        (date1.day == date2.day);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return ListView.builder(
        reverse: true,
        itemCount: data.documents.length,
        itemBuilder: (context, i) {
          var months = [
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December'
          ];
          DateTime when = data.documents[i].data["when"].toDate().toLocal();
          bool isMine = (data.documents[i].data["from"] as String) == user.uid;
          List<Widget> widgetsToShow = [
            Message(
              fromMe: isMine,
              msg: data.documents[i].data['msg'],
              when: when,
            )
          ];
          if (i == data.documents.length - 1) {
            widgetsToShow.insert(
                0,
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                        "${when.day} ${months[when.month - 1]} ${when.year}",
                        style: Theme.of(context).textTheme.subtitle1)));
          } else if (!areSameDay(data.documents[i + 1].data["when"],
              data.documents[i].data["when"])) {
            widgetsToShow.insert(
                0,
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                        "${when.day} ${months[when.month - 1]} ${when.year}",
                        style: Theme.of(context).textTheme.subtitle1)));
          }
          return Column(
            children: widgetsToShow,
          );
        });
  }
}
