import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'helper_classes.dart';
import 'other_user_profile.dart';

class CommentPage extends StatefulWidget {
  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {

  final List<String> whoDoes = <String>["A specific person",'Myself','Anyone'];
  final List<String> charities = <String>["Cancer Research",'British Heart Foundation','Oxfam'];
  int selected = -1;
  int charity = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("11 comments"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close), 
            onPressed: () => Navigator.of(context).pop(null),
            )
        ],
        leading: new Container(),
      ),
      body: Column(
        children: [Expanded(child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          itemCount: 12,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: GestureDetector(
                child: AspectRatio(
                aspectRatio: 1/1,
                child: Container(
                  child: ProfilePic("https://i.imgur.com/BoN9kdC.png", 40),
                  margin: EdgeInsets.all(10.0),            
                )
              ),
              onTap: (){
                Navigator.of(context).push(_viewUser());
              },
            ),
            title: Column(
              children: [RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                    fontFamily: 'Muli',
                  ),
                  children: [
                    TextSpan(text: 'username ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: 'I would like to comment profusely largely on this fundraiser, actually rather quite a large chunk of text do I want to comment in. I really care about this fundraiser.'),
                  ]
                ),
              ), Row(
                children: [Container(
                  alignment: Alignment.centerLeft,
                  width: 40,
                  margin: EdgeInsets.all(5),
                  child: Text(
                    '7h',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    )
                    ),
                  ), Container(
                  alignment: Alignment.centerLeft,
                  width: 150,
                  margin: EdgeInsets.all(5),
                  child: Text(
                    '3 likes',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    )
                    ),
                  ),]
                )
              ],
            ),
            trailing: GestureDetector(
              child: Container(
                child: GestureDetector(
                  child: Container(
                    width: 20,
                    height: 20,
                    padding: const EdgeInsets.all(0.0), child: Image.asset('assets/images/like.png'),
                  ),
                  onTap: () {
                    final snackBar = SnackBar(content: Text("Like passed"));
                    Scaffold.of(context).showSnackBar(snackBar);
                  },
                ),  
              ),
            ),
            );         
          },
          separatorBuilder: (BuildContext context, int index){
            return SizedBox(
              height: 2,
            );
          },
        )), Row(
          children: [
            Container(
              height:80,
            child: AspectRatio(
            aspectRatio: 1/1,
            child: Container(
              child: ProfilePic("https://i.imgur.com/BoN9kdC.png", 40),         
              margin: EdgeInsets.all(20.0),            
            )
          ),
          ), Expanded( 
            child: Container(
              height: 80,
              margin: EdgeInsets.only(right:20),
              padding: EdgeInsets.symmetric(vertical:20),
              child: TextField(
                
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(20.0),
                    ),
                  ),
                  hintText: "Add a comment...",
                  contentPadding: EdgeInsets.only(bottom: 20, left:10)
                ),
              )
          )),
          ]
        ) 
      ]),
    );
  }
}

Route _viewUser() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => ViewUser(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}