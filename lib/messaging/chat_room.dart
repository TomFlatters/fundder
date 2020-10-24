import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/messaging/messageList.dart';
import 'package:fundder/messaging/messagingService.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/shared/constants.dart';

import '../helper_classes.dart';

class ChatRoom extends StatelessWidget {
  final String otherChateeUid;
  final String otherChateeUsername;
  final TextEditingController _messageController = TextEditingController();
  ChatRoom(this.otherChateeUid, this.otherChateeUsername);

  @override
  Widget build(BuildContext context) {
    print("building chat page");
    var user = Provider.of<User>(context);
    MessagingService messagingService = MessagingService(user.uid);
    String chatId = MessagingService.getChatRoomId(user.uid, otherChateeUid);

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                messagingService.leaveChat(chatId);
                Navigator.of(context).pop();
              }),
          centerTitle: true,
          title: ListTile(
            leading: ProfilePic(otherChateeUid, 40),
            title: Text(
              otherChateeUsername,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/user/' + otherChateeUid);
            },
          )),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
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
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Write your message'),
                      onSubmitted: (txt) {
                        //maybe this won't be necessary
                        //sendText(txt);
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    print("pressed send msg icon");
                    messagingService.sendText(_messageController.text, chatId);
                    _messageController.clear();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
