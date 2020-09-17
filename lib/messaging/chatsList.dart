import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatsList extends StatelessWidget {
  ChatsList(this.data);
  final QuerySnapshot data;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: data.documents.length,
      itemBuilder: (context, i) {
        var chat = data.documents[i];
        return Text(chat.data["latestMessage"]);
      },
    );
  }
}
