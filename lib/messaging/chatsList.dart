import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/messaging/chat_room.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/routes/FadeTransition.dart';
import 'package:provider/provider.dart';

class ChatsList extends StatelessWidget {
  ChatsList(this.data);
  final QuerySnapshot data;
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context);
    return ListView.builder(
      itemCount: data.documents.length,
      itemBuilder: (context, i) {
        var chat = data.documents[i];
        var leftChat = chat.data["leftChat"];

        var latestMessage = chat.data["latestMessage"];
        var latestTxt =
            (latestMessage is String) ? latestMessage : latestMessage['txt'];
        String latestMessageTimestamp;
        if (latestMessage is String) {
          latestMessageTimestamp = "";
        } else {
          zeroFy(n) => (n < 10) ? ("0${n}") : n.toString();
          var when = latestMessage['timeStamp'].toDate().toLocal();
          latestMessageTimestamp =
              (zeroFy(when.hour) + ":" + zeroFy(when.minute));
        }
        bool unread;
        if (leftChat != null) {
          var latestMessageTimestamp = latestMessage['timeStamp'].toDate();
          if (leftChat[user.uid] != null) {
            var timeLeftChat = leftChat[user.uid].toDate();
            unread = timeLeftChat.isBefore(latestMessageTimestamp);
          } else {
            unread = true;
          }
        }

        var chatMembers = chat.data["chatMembers"];
        var otherChateeId =
            (chatMembers[0] == user.uid) ? chatMembers[1] : chatMembers[0];
        return FutureBuilder(
          future: _getUserNamebyUid(otherChateeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListTile(
                  leading: ProfilePic(otherChateeId, 40),
                  trailing: Text(latestMessageTimestamp),
                  title: Text(snapshot.data),
                  subtitle: Text(latestTxt,
                      style: (unread)
                          ? TextStyle(fontWeight: FontWeight.bold)
                          : null),
                  onTap: () => Navigator.push(context,
                      FadeRoute(page: ChatRoom(otherChateeId, snapshot.data))));
            } else {
              return Container(
                height: 40,
              );
            }
          },
        );
      },
    );
  }
}

Future<String> _getUserNamebyUid(uid) async {
  CollectionReference userCollection = Firestore.instance.collection('users');
  var docSnap = await userCollection.document(uid).get();
  return (docSnap.exists) ? docSnap.data['username'] : "-";
}
