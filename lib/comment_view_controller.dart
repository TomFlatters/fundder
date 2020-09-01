import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'package:fundder/services/comments_service.dart';
import 'helper_classes.dart';
import 'models/post.dart';
import 'services/database.dart';
import 'models/user.dart';
import 'package:provider/provider.dart';
import 'shared/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentPage extends StatefulWidget {
  final String pid;

  CommentPage({this.pid});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _textController = TextEditingController();
  Post postData;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    CommentsService commentsService =
        CommentsService(uid: user.uid, postId: widget.pid);
    return StreamBuilder(
        stream: commentsService.comments(),
        builder: (context, snapshot) {
          List comments;
          if (!snapshot.hasData) {
            comments = [];
          } else {
            comments = snapshot.data.map((s) => s.data).toList();
          }
          print('comments: ' + comments.toString());
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(comments.length.toString() + " comments"),
              actions: <Widget>[
                new IconButton(
                  icon: new Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(null),
                )
              ],
              leading: new Container(),
            ),
            body: Column(children: [
              Expanded(
                  child: ListView.separated(
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                itemCount: comments.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                          context, '/user/' + comments[index]['uid']);
                    },
                    leading: ProfilePic(comments[index]['uid'], 40),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          child: Text(
                            comments[index]["username"],
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontFamily: 'Neue Haas Unica',
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(comments[index]["text"]),
                        Row(children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child:
                                Text(howLongAgo(comments[index]["timestamp"]),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    )),
                          ),
                        ])
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 2,
                  );
                },
              )),
              Row(children: [
                //bottom comment input bar
                Container(
                  height: 80,
                  child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        child: ProfilePic(user.uid, 40),
                        margin: EdgeInsets.all(20.0),
                      )),
                ),
                Expanded(
                    child: Row(children: [
                  Expanded(
                      child: Container(
                          height: 80,
                          margin: EdgeInsets.only(right: 20),
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(20.0),
                                  ),
                                ),
                                hintText: "Add a comment...",
                                contentPadding:
                                    EdgeInsets.only(bottom: 20, left: 10)),
                          ))),
                  FutureBuilder(
                    future: DatabaseService(uid: user.uid).readUserData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        String username = snapshot.data.username;
                        return GestureDetector(
                          child: Container(
                            child: GestureDetector(
                              child: Container(
                                  width: 70,
                                  height: 80,
                                  padding: const EdgeInsets.only(right: 25.0),
                                  child: Center(
                                    child: Text('Send'),
                                  )),
                              onTap: () {
                                Map comment = {
                                  "uid": user.uid,
                                  "username": username,
                                  "text": _textController.text,
                                  "timestamp": DateTime.now()
                                };
                                if (_textController.text != "") {
                                  commentsService.addAcomment(comment);
                                  _textController.text = '';
                                }
                              },
                            ),
                          ),
                        );
                      } else {
                        return Container(
                            width: 70,
                            height: 80,
                            padding: const EdgeInsets.only(right: 25.0),
                            child: Center(
                              child: Text('Send'),
                            ));
                      }
                    },
                  ),
                ])),
              ])
            ]),
          );
        });
  }
}
