import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/models/user.dart';
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
        var latestMessage = chat.data["latestMessage"];
        var chatMembers = chat.data["chatMembers"];
        var otherChateeId =
            (chatMembers[0] == user.uid) ? chatMembers[1] : chatMembers[0];
        return FutureBuilder(
          future: _getUserNamebyUid(otherChateeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListTile(
                  leading: ProfilePic(otherChateeId, 40),
                  title: Text(snapshot.data),
                  subtitle: Text(latestMessage));
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
