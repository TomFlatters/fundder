import 'package:flutter/material.dart';
import 'helper_classes.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'share_post_view.dart';
import 'donate_page_controller.dart';
import 'comment_view_controller.dart';

class ViewPost extends StatefulWidget {
  @override
  _ViewPostState createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {

  final List<String> whoDoes = <String>["A specific person",'Myself','Anyone'];
  final List<String> charities = <String>["Cancer Research",'British Heart Foundation','Oxfam'];
  int selected = -1;
  int charity = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Post Title"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close), 
            onPressed: () => Navigator.of(context).pop(null),
            )
        ],
        leading: new Container(),
      ),
      body:
        ListView(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal:10),
                      height: 60,
                      child: Row(
                        children: <Widget>[Align(
                          alignment: Alignment.centerLeft,
                          child: AspectRatio(
                            aspectRatio: 1/1,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(
                                      "https://i.imgur.com/BoN9kdC.png")
                                )
                              ),
                              margin: EdgeInsets.all(10.0),            
                            )
                          )
                        ), Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Profile 1'
                          )
                        ), Expanded(
                          child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: EdgeInsets.all(10.0),
                            child: Text(
                            'For Charity 1'
                            )
                          )
                          )
                        ),
                        ],
                      ),
                    ), Container(
                      child: FittedBox(
                        child: Image.network('https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg'),
                        fit: BoxFit.fill,
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                    ), Container(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      height: 30,
                      child: Row(children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            child: Row(
                              children:[
                                Container(
                                  width: 20,
                                  height: 20,
                                  padding: const EdgeInsets.all(0.0), child: Image.asset('assets/images/like.png'),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text('${10}',textAlign: TextAlign.left,)
                                  )
                                )
                              ]
                            ),
                            onPressed: (){
                              final snackBar = SnackBar(content: Text("Tap"));
                              Scaffold.of(context).showSnackBar(snackBar);
                            },
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            child: Row(
                              children:[
                                Container(
                                  width: 20,
                                  height: 20,
                                  padding: const EdgeInsets.all(0.0), child: Image.asset('assets/images/comment.png'),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text('${5}',textAlign: TextAlign.left,)
                                  )
                                )
                              ]
                            ),
                            onPressed: () {Navigator.of(context).push(_showComments());},
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            child: Row(
                              children:[
                                Container(
                                  width: 20,
                                  height: 20,
                                  padding: const EdgeInsets.all(0.0), child: Image.asset('assets/images/share.png'),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: Text('Share',textAlign: TextAlign.left,)
                                  )
                                )
                              ]
                            ),
                            onPressed: () {_showShare();},
                          ),
                        )
                      ]
                      ),
                    ), Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        '£${5} raised of £${15} target',
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      )
                    ), Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: LinearPercentIndicator(
                        
                        lineHeight: 7,
                        percent: 5/15,
                        backgroundColor: HexColor('CCCCCC'),
                        progressColor: HexColor("A3D165"),
                      ),
                    ), Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Text(
                        'This is a longer description of whatever the fuck they are doing'
                      )
                    ), GestureDetector(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        margin: EdgeInsets.only(left: 70, right:70, bottom: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Text(
                          "Donate",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      onTap: (){ Navigator.of(context).push(_openDonate());
                      }
                    ),
                  ],
                )
              )
            )
          ], 
          ),
    );
  }

  void _showShare() {
  showModalBottomSheet(
    context: context, 
    builder: (context) {
      return SharePost();
    }
    );
  }
}

Route _openDonate() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => DonatePage(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}

Route _showComments() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => CommentPage(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}