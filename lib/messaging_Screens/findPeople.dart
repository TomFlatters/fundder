import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/services/database.dart';
import 'package:provider/provider.dart';

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
            onSearch: search,
            onItemFound: (DocumentSnapshot doc, int index) {
              return Text(doc.data.toString());
            },
            minimumChars: 1,
          ),
        ),
      ),
    );
  }
}
