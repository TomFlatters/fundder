import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:fundder/messaging/chat_room.dart';
import 'package:fundder/messaging/chatsList.dart';
import 'package:fundder/messaging/findPeople.dart';
import 'package:fundder/messaging/messagingService.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/routes/FadeTransition.dart';

import 'package:fundder/services/database.dart';
import 'package:fundder/shared/loading.dart';
import 'package:provider/provider.dart';

import '../helper_classes.dart';

import 'package:flutter_icons/flutter_icons.dart';

class ChatLobby extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context);
    Future<List<DocumentSnapshot>> search(
      String search,
    ) async {
      search = search.toLowerCase();
      return DatabaseService(uid: user.uid).usersContainingString(search);
    }

    MessagingService messagingService = MessagingService(user.uid);
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(AntDesign.close),
            onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
              icon: Icon(AntDesign.edit),
              onPressed: () {
                Navigator.push(context, FadeRoute(page: FindChatUsers()));
              })
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SearchBar(
            emptyWidget: Center(child: Text('No results for this search')),
            placeHolder: StreamBuilder(
                stream: messagingService.getChats(),
                builder: (context, snapshot) => snapshot.hasData
                    ? ChatsList(snapshot.data as QuerySnapshot)
                    : Center(
                        child: Loading(),
                      )),
            hintText: 'Search',
            onSearch: search,
            onItemFound: (DocumentSnapshot doc, int index) {
              return ListTile(
                leading: ProfilePicFromUrl(doc.data['profilePic'], 40),
                title: Text(
                  doc.data['username'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Navigator.push(
                    context,
                    FadeRoute(
                        page: ChatRoom(doc.documentID, doc.data['username']))),
              );
            },
            minimumChars: 1,
          ),
        ),
      ),
    );
  }
}
