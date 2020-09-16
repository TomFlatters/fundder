import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:fundder/messaging/findPeople.dart';
import 'package:fundder/routes/FadeTransition.dart';

class ChatLobby extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
              icon: Icon(Icons.border_color),
              onPressed: () {
                Navigator.push(context, FadeRoute(page: FindChatUsers()));
              })
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SearchBar(
            hintText: 'search existing chats',
            onSearch: null,
            onItemFound: null,
          ),
        ),
      ),
    );
  }
}
