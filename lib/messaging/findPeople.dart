import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:fundder/messaging/chat_room.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/routes/FadeTransition.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/services/followers.dart';
import 'package:provider/provider.dart';

import '../helper_classes.dart';

class FindChatUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    Future<List<DocumentSnapshot>> search(
      String search,
    ) async {
      search = search.toLowerCase();
      return DatabaseService(uid: user.uid).usersContainingString(search);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose People'),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SearchBar(
            placeHolder: _displyFollowers(user.uid),
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

Widget _displyFollowers(uid) {
  return FutureBuilder(
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        var users = snapshot.data;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var uname = users[index]["username"];
            var otherChateeId = users[index]["uid"];
            return ListTile(
              leading: ProfilePic(otherChateeId, 40),
              title: Text(
                uname,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                    context, FadeRoute(page: ChatRoom(otherChateeId, uname)));
              },
            );
          },
        );
      } else {
        return Container();
      }
    },
    future: GeneralFollowerServices.unamesFollowedByUser(uid),
  );
}
