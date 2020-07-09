import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'helper_classes.dart';
import 'other_user_profile.dart';
import 'models/post.dart';
import 'services/database.dart';
import 'models/user.dart';
import 'package:provider/provider.dart';
import 'shared/helper_functions.dart';

class CommentPage extends StatefulWidget {
  final String postData;
  CommentPage({this.postData});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final _textController = TextEditingController();
  Post postData;
  List comments;

  @override
  void initState() {
    //print(widget.postData);
    //_getPost();
    DatabaseService(uid: widget.postData)
        .getPostById(widget.postData)
        .then((post) => {
              setState(() {
                print("set state");
                print(post);
                postData = post;
                if (postData.comments == {}) {
                  comments = [];
                } else {
                  comments = postData.comments;
                }
              })
            });
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return new StreamBuilder(
        stream: DatabaseService(uid: user.uid).commentsByDocId(widget.postData),
        // widget.feedChoice == 'user'
        //   ? Firestore.instance.collection("posts").where("author", isEqualTo: widget.identifier).snapshots()
        //   : Firestore.instance.collection("posts").snapshots(),
        builder: (context, snapshot) {
          // print(snapshot.data);
          if (!snapshot.hasData) {
            comments = [];
          } else {
            comments = snapshot.data;
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
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                itemCount: comments.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    /*leading: GestureDetector(
                      child: AspectRatio(
                          aspectRatio: 1 / 1,
                          child: Container(
                            child: ProfilePic(
                                "https://i.imgur.com/BoN9kdC.png", 40),
                            margin: EdgeInsets.all(10.0),
                          )),
                      onTap: () {
                        Navigator.pushNamed(context, '/username');
                      },
                    ),*/
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          child: Text(
                            comments[index]["author"],
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontFamily: 'Muli',
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/username');
                          },
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
                          /*Container(
                      alignment: Alignment.centerLeft,
                      width: 150,
                      margin: EdgeInsets.all(5),
                      child: Text('3 likes',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          )),
                    ),*/
                        ])
                      ],
                    ),
                    /*trailing: GestureDetector(
                child: Container(
                  child: GestureDetector(
                    child: Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(0.0),
                      child: Image.asset('assets/images/like.png'),
                    ),
                    onTap: () {
                      final snackBar = SnackBar(content: Text("Like passed"));
                      Scaffold.of(context).showSnackBar(snackBar);
                    },
                  ),
                ),
              ),*/
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 2,
                  );
                },
              )),
              Row(children: [
                Container(
                  height: 80,
                  child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        child:
                            ProfilePic("https://i.imgur.com/BoN9kdC.png", 40),
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
                  GestureDetector(
                    child: Container(
                      child: GestureDetector(
                        child: Container(
                          width: 80,
                          height: 40,
                          padding: const EdgeInsets.all(0.0),
                          child: Text('Send'),
                        ),
                        onTap: () {
                          Map comment = {
                            "author": user.uid,
                            "text": _textController.text,
                            "timestamp": DateTime.now()
                          };
                          DatabaseService(uid: user.uid)
                              .addCommentToPost(comment, postData.id);
                          _textController.text = '';
                        },
                      ),
                    ),
                  ),
                ])),
              ])
            ]),
          );
        });
  }
}
