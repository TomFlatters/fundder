import 'package:flutter/material.dart';

class FeedController extends StatelessWidget {
 final Color color;

FeedController(this.color);

 @override
 Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Feed'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Do'),
              Tab(text: 'Fund'),
              Tab(text: 'Done'),
            ],
          ),
        ),
      ),
    );
 }
}