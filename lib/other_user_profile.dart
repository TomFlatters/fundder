import 'package:flutter/material.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/shared/loading.dart';
import 'feed.dart';
import 'models/user.dart';
import 'helper_classes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global widgets/buttons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'models/post.dart';
import 'package:flutter/cupertino.dart';

class ViewUser extends StatefulWidget {
  @override
  _ViewUserState createState() => _ViewUserState();

  final String uid;
  ViewUser({this.uid});
}

class _ViewUserState extends State<ViewUser>
    with SingleTickerProviderStateMixin {
  int limit = 3;
  Timestamp loadingTimestamp;
  List<Post> postList;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  TabController _tabController;
  String _username = "Username";
  String _name = "Name";
  String _uid;
  String _email = "Email";
  String _profilePic =
      'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/images%2Fprofile_pic_default-01.png?alt=media&token=cea24849-7590-43f8-a2ff-b630801e7283';

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _retrieveUser();
    _onRefresh();
    super.initState();
  }

  void _retrieveUser() async {
    //var firebaseUser = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection("users")
        .document(widget.uid)
        .get()
        .then((value) {
      setState(() {
        _uid = widget.uid;
        _name = value.data["name"];
        _username = value.data['username'];
        _profilePic = value.data["profilePic"];
        if (_profilePic == null) {
          _profilePic =
              'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/images%2Fprofile_pic_default-01.png?alt=media&token=cea24849-7590-43f8-a2ff-b630801e7283';
          DatabaseService(uid: _uid)
              .updateUserData(_email, _username, _name, _profilePic);
        }
      });
    });
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
        future: DatabaseService(uid: widget.uid).readUserData(),
        builder: (BuildContext context, AsyncSnapshot<User> userData) {
          print(userData);
          if (userData.connectionState == ConnectionState.waiting) {
            return Loading();
          } else {
            if (userData.hasError)
              return Center(child: Text('Error: ${userData.error}'));
            else
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(_username),
                  actions: <Widget>[
                    new IconButton(
                      icon: new Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(null),
                    )
                  ],
                  leading: new Container(),
                ),
                body: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  header: WaterDropHeader(),
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = Text("pull up load");
                      } else if (mode == LoadStatus.loading) {
                        body = CupertinoActivityIndicator();
                      } else if (mode == LoadStatus.failed) {
                        body = Text("Load Failed!Click retry!");
                      } else if (mode == LoadStatus.canLoading) {
                        body = Text("release to load more");
                      } else {
                        body = Text("No more Data");
                      }
                      return Container(
                        height: 55.0,
                        child: Center(child: body),
                      );
                    },
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: ListView(shrinkWrap: true,
                      //physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 20, bottom: 10),
                          alignment: Alignment.center,
                          child: Container(
                            child: ProfilePicFromUrl(_profilePic, 90),
                            margin: EdgeInsets.all(10.0),
                          ),
                        ),
                        Center(
                          child: Text(_username),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 20),
                            height: 50,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: GestureDetector(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.topCenter,
                                        child: Text("54",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                      Expanded(
                                          child: Container(
                                        alignment: Alignment.bottomCenter,
                                        child: Text("Following"),
                                      )),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(context,
                                        '/user/' + widget.uid + '/followers');
                                  },
                                )),
                                Expanded(
                                    child: GestureDetector(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.topCenter,
                                        child: Text("106",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            )),
                                      ),
                                      Expanded(
                                          child: Container(
                                        alignment: Alignment.bottomCenter,
                                        child: Text("Followers"),
                                      )),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(context,
                                        '/user/' + widget.uid + '/followers');
                                  },
                                )),
                                Expanded(
                                    child: Column(
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.topCenter,
                                      child: Text("£54",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                                    Expanded(
                                        child: Container(
                                      alignment: Alignment.bottomCenter,
                                      child: Text("Raised"),
                                    )),
                                  ],
                                )),
                              ],
                            )),
                        EditFundderButton(
                          text: "Follow",
                          onPressed: () {},
                        ),
                        DefaultTabController(
                          length: 1,
                          initialIndex: 0,
                          child: Column(
                            children: [
                              TabBar(
                                tabs: [
                                  Tab(text: 'Posts') /*, Tab(text: 'Liked')*/
                                ],
                                controller: _tabController,
                              ),
                              [
                                FeedView('feedChoice', 'identifier',
                                    HexColor('ff6b6c'), postList),
                                FeedView('feedChoice', 'identifier',
                                    HexColor('ff6b6c'), postList),
                              ][_tabController.index]
                            ],
                          ),
                        )
                      ]),
                ),
              );
          }
        });
  }

  void _onRefresh() async {
    // monitor network fetch
    loadingTimestamp = Timestamp.now();
    List<Post> futurePost = await DatabaseService().authorPosts(widget.uid);
    postList = futurePost;
    Post post = futurePost.last;
    print('postList' + postList.toString());
    loadingTimestamp = post.timestamp;
    if (mounted) setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
}
