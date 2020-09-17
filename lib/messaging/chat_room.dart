import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/messaging/messageList.dart';
import 'package:fundder/messaging/messagingService.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/shared/loading.dart';
import 'package:provider/provider.dart';

import '../helper_classes.dart';

class ChatRoom extends StatelessWidget {
  final DocumentSnapshot otherChatee;
  final TextEditingController _messageController = TextEditingController();
  ChatRoom(this.otherChatee);

  @override
  Widget build(BuildContext context) {
    print("building chat page");
    var user = Provider.of<User>(context);
    String chatId =
        MessagingService.getChatRoomId(user.uid, otherChatee.documentID);

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop()),
          centerTitle: true,
          title: ListTile(
            leading: ProfilePicFromUrl(otherChatee.data['profilePic'], 40),
            title: Text(
              otherChatee.data['username'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/user/' + otherChatee.documentID);
            },
          )),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
                  stream: MessagingService.getMessages(chatId),
                  builder: (context, snapshot) => snapshot.hasData
                      ? MessagesList(snapshot.data as QuerySnapshot)
                      : Center(
                          child: Loading(),
                        ))),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _messageController,
                    keyboardType: TextInputType.text,
                    onSubmitted: (txt) {
                      //maybe this won't be necessary
                      //sendText(txt);
                      _messageController.clear();
                    },
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  // sendText(_messageController.text);
                  print("pressed send msg icon");
                  _messageController.clear();
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
