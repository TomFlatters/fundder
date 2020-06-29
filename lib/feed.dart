import 'package:flutter/material.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/shared/helper_functions.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'models/post.dart';
import 'view_post_controller.dart';
import 'share_post_view.dart';
import 'helper_classes.dart';
import 'comment_view_controller.dart';
import 'other_user_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedView extends StatefulWidget {

  @override
  _FeedViewState createState() => _FeedViewState();

  final Color colorChoice;
  final String feedChoice;
  final String identifier;
  final Stream<List<Post>> postsStream;
  FeedView(this.feedChoice, this.identifier, this.colorChoice, this.postsStream);

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
    return new StreamBuilder(
          stream: widget.postsStream,
          // widget.feedChoice == 'user'
          //   ? Firestore.instance.collection("posts").where("author", isEqualTo: widget.identifier).snapshots()
          //   : Firestore.instance.collection("posts").snapshots(),
          builder: (context, snapshot) {
            // print(snapshot.data);
            if (!snapshot.hasData){
              return Text("No data...");
            } else {
              return ListView.separated(
                physics: physics,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 10.0),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Post postData = snapshot.data[index];
                  // print(postData);
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
                                      child: ProfilePic("https://i.imgur.com/BoN9kdC.png", 40),
                                      margin: EdgeInsets.all(10.0),            
                                    )
                                  ),
                                  onTap: () {Navigator.of(context).push(_viewUser());},
                                )
                              ), Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  postData.author
                                  /*style: TextStyle(
                                    fontFamily: 'Roboto Mono'
                                  ),*/
                                )
                              ), Expanded(
                                child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: EdgeInsets.all(10.0),
                                  child: Text(
                                    postData.charity
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
                              postData.subtitle
                            )
                          ), Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.all(10),
                            child: Text(
                              '£${postData.amountRaised} raised of £${postData.targetAmount} target',
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
                              percent: postData.percentRaised(),
                              backgroundColor: HexColor('CCCCCC'),
                              progressColor: widget.colorChoice,
                            ),
                            ), Container(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width*9/16,
                                  child: CachedNetworkImage(
                                    imageUrl: (postData.imageUrl != null) ? postData.imageUrl : 'https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg',
                                    placeholder: (context, url) => Loading(),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),//Image.network('https://ichef.bbci.co.uk/news/1024/branded_pidgin/EE19/production/_111835906_954176c6-5c0f-46e5-9bdc-6e30073588ef.jpg'),
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
                                          child: Text(postData.likes.length.toString(),textAlign: TextAlign.left,)
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
                                          child: Text(postData.comments.length.toString(),textAlign: TextAlign.left,)
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
                              howLongAgo(postData.timestamp),
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
                  onTap: () {
                    print(postData);
                    Navigator.of(context).push(_createRoute(postData));}
                  ,);
                },
                separatorBuilder: (BuildContext context, int index){
                  return SizedBox(
                    height: 10,
                  );
                },
              );
          }
        }
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

  List<Post> _postsDataFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc){
      // print(doc.data['timestamp'].toString());
      return Post(
        author: doc.data['author'],
        title: doc.data['title'],
        charity: doc.data['charity'],
        amountRaised: doc.data['amountRaised'],
        targetAmount: doc.data['targetAmount'],
        likes: doc.data['likes'],
        comments: doc.data['comments'],
        subtitle: doc.data['subtitle'],
        timestamp: doc.data['timestamp'],
      );
    }).toList();
  }

  
}

Route _showComments() {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => CommentPage(),
    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
    transitionDuration: Duration(milliseconds: 300),
  );
}

// Create route is called when user clicks on a post.
Route _createRoute(Post postData) {
  return PageRouteBuilder(
    pageBuilder: (c, a1, a2) => ViewPost(postData: postData),
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