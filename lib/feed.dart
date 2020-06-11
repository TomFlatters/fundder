import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'view_post_controller.dart';
import 'share_post_view.dart';
import 'helper_classes.dart';
import 'comment_view_controller.dart';
import 'other_user_profile.dart';

class FeedView extends StatefulWidget {

  @override
  _FeedViewState createState() => _FeedViewState();

  final Color colorChoice;
  final String feedChoice;
  FeedView(this.feedChoice, this.colorChoice);

}

class _FeedViewState extends State<FeedView> {

  ScrollPhysics physics;

  @override
  void initState() {
    super.initState();
    if (widget.feedChoice == 'user') {
      physics = NeverScrollableScrollPhysics();
      print('user');
    } else {
      physics = AlwaysScrollableScrollPhysics();
      print('nonuser');
    }
  }

  @override
  void didUpdateWidget(FeedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feedChoice == 'user') {
      physics = NeverScrollableScrollPhysics();
      print('user');
    } else {
      physics = AlwaysScrollableScrollPhysics();
      print('nonuser');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> entries = <String>['A', 'B', 'C'];
    return ListView.separated(
      physics: physics,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 10.0),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: Container(
          color: Colors.white,
          child: Container(
            margin: EdgeInsets.only(left: 0, right: 0, top:0),
            child: Column(
              children: <Widget>[
                Container(
                  height: 60,
                  child: Row(
                    children: <Widget>[Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
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
                        ),
                        onTap: () {Navigator.of(context).push(_viewUser());},
                      )
                    ), Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Profile ${entries[index]}'
                      )
                    ), Expanded(
                      child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.all(10.0),
                        child: Text(
                        'For Charity ${entries[index]}'
                        )
                      )
                      )
                    ),
                    ],
                  ),
                ), Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.all(10),
                  child: Text(
                    'I want somebody to do xyzlkklsadfljsdfl jsadfsadf; dsfdfjsladfsljfdsa;dfsa'
                  )
                ), Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.all(10),
                  child: Text(
                    '£${(index+15)/4} raised of £${index+10} target',
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  )
                ), Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  child: LinearPercentIndicator(
                    linearStrokeCap: LinearStrokeCap.butt,
                    lineHeight: 5,
                    percent: ((index+15)/4)/(index+10),
                    backgroundColor: HexColor('CCCCCC'),
                    progressColor: widget.colorChoice,
                  ),
                  ), Container(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width*9/16,
                        child: Image.network('https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg'),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      ), Container(
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
                                child: Text('$index',textAlign: TextAlign.left,)
                              )
                            )
                          ]
                        ),
                        onPressed: (){
                          final snackBar = SnackBar(content: Text("Like passed"));
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
                                child: Text('$index',textAlign: TextAlign.left,)
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
                  margin: EdgeInsets.all(10),
                  child: Text(
                    'x hours ago',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    )
                    ),
                  )
              ],
            )
          )
        ),
        onTap: () {Navigator.of(context).push(_createRoute());}
        ,);
      },
      separatorBuilder: (BuildContext context, int index){
        return SizedBox(
          height: 10,
        );
      },
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

Route _showComments() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => CommentPage(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => ViewPost(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}

Route _viewUser() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => ViewUser(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}