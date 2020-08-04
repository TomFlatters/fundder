import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fundder/post_widgets/likeBar.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/services/likes.dart';
import 'package:fundder/view_post_controller.dart';
import 'feed.dart';
import 'profile_actions_view.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/services/database.dart';
import 'package:provider/provider.dart';
import 'helper_classes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_pages/web_menu.dart';
import 'models/user.dart';
import 'shared/loading.dart';
import 'global_widgets/buttons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'models/post.dart';
import 'package:flutter/cupertino.dart';

class ProfileController extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();

  final String uid;
  ProfileController({this.uid});
}

class _ProfileState extends State<ProfileController>
    with SingleTickerProviderStateMixin {
  int limit = 3;
  Timestamp loadingTimestamp;
  List<Post> postList;
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  final AuthService _auth = AuthService();

  TabController _tabController;
  String _username = "Username";
  String _name = "Name";
  String _uid;
  String _email = "Email";
  String _profilePic;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    print("uid: " + widget.uid);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _retrieveUser();
    super.initState();
  }

  void _retrieveUser() async {
    Firestore.instance
        .collection("users")
        .document(widget.uid)
        .get()
        .then((value) {
      setState(() {
        _uid = widget.uid;
        _name = value.data["name"];
        _username = value.data['username'];
        _email = value.data["email"];
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
    final user = Provider.of<User>(context);
    // print(user.uid);
    if (user == null && kIsWeb == true) {
      Future.microtask(() => Navigator.pushNamed(context, '/web/login'));
      return Scaffold(
        body: Text(
          "Redirecting",
          style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 20,
              color: Colors.black,
              decoration: null),
        ),
      );
    } else
    // This size provide us total height and width  of our screen
    {
      return new StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(widget.uid)
              .snapshots(),
          // widget.feedChoice == 'user'
          //   ? Firestore.instance.collection("posts").where("author", isEqualTo: widget.identifier).snapshots()
          //   : Firestore.instance.collection("posts").snapshots(),
          builder: (context, snapshot) {
            // print(snapshot.data);
            if (snapshot.hasData) {
              if (snapshot.data['name'] != null) {
                _name = snapshot.data["name"];
              }
              _email = snapshot.data["email"];
              _profilePic = snapshot.data["profilePic"];
              print("has data");
            }

            return _username == null
                ? Loading()
                : Scaffold(
                    appBar: kIsWeb == true
                        ? null
                        : AppBar(
                            centerTitle: true,
                            title: Text(_username),
                            actions: _uid == user.uid
                                ? <Widget>[
                                    FlatButton(
                                      onPressed:
                                          () /*async {
            await _auth.signOut();
          }*/
                                          {
                                        _showOptions();
                                      },
                                      child: Icon(AntDesign.ellipsis1),
                                    )
                                  ]
                                : null),
                    body: Column(children: [
                      kIsWeb == true ? WebMenu(5) : Container(),
                      Expanded(
                        child: SmartRefresher(
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
                          child: ListView(shrinkWrap: true, children: <Widget>[
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
                                        Navigator.pushNamed(
                                            context,
                                            '/user/' +
                                                widget.uid +
                                                '/followers');
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
                                        Navigator.pushNamed(
                                            context,
                                            '/user/' +
                                                widget.uid +
                                                '/followers');
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
                            _uid == user.uid
                                ? EditFundderButton(
                                    text: 'Edit Profile',
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/account/edit');
                                    })
                                : EditFundderButton(
                                    text: "Follow",
                                    onPressed: () {},
                                  ),
                            DefaultTabController(
                              length: 2,
                              initialIndex: 0,
                              child: Column(
                                children: [
                                  TabBar(
                                    tabs: [
                                      Tab(text: 'Posts'),
                                      Tab(text: 'Liked')
                                    ],
                                    controller: _tabController,
                                  ),
                                  [
                                    _profileView(user.uid),
                                    _profileView(user.uid)
                                  ][_tabController.index]
                                ],
                              ),
                            )
                          ]),
                        ),
                      ),
                    ]),
                  );
          });
    }
  }

  Widget _profileView(String uid) {
    LikesService likesService = LikesService(uid: uid);

    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: postList != null ? postList.length : 0,
        itemBuilder: (BuildContext context, int index) {
          bool initiallyHasLiked;
          int initialLikesNo;
          Post post = postList[index];
          return FutureBuilder(
              future: likesService.hasUserLikedPost(post.id),
              builder: (context, hasLiked) {
                if (hasLiked.connectionState == ConnectionState.done) {
                  initiallyHasLiked = hasLiked.data;
                  return FutureBuilder(
                    future: likesService.noOfLikes(post.id),
                    builder: (context, noLikes) {
                      if (noLikes.connectionState == ConnectionState.done) {
                        initialLikesNo = noLikes.data;
                        var likesModel = LikesModel(
                            initiallyHasLiked, initialLikesNo,
                            uid: uid, postId: post.id);
                        return ListTile(
                          leading: ProfilePic(post.author, 40),
                          title: Text(post.title),
                          subtitle: Text(post.subtitle),
                          trailing: post.status == 'done'
                            ? Icon(
                                Ionicons.ios_checkmark_circle,
                                color: HexColor('ff6b6c'),
                              )
                            : Container(width: 0),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewPost(
                                        postData: post.id,
                                        likesModel: likesModel)));
                          },
                        );
                      } else {
                        return ListTile();
                      }
                    },
                  );
                } else {
                  return ListTile();
                }
              });
        });
  }

  void _onRefresh() async {
    // monitor network fetch
    loadingTimestamp = Timestamp.now();
    List<Post> futurePost = await DatabaseService().authorPosts(widget.uid);
    if (futurePost != null) {
      if (futurePost.isEmpty == false) {
        postList = futurePost;
        Post post = futurePost.last;
        print('postList' + postList.toString());
        loadingTimestamp = post.timestamp;
      }
    }
    if (mounted) setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _showOptions() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ProfileActions();
        });
  }
}
