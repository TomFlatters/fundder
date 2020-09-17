import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fundder/post_widgets/likeBar.dart';
import 'package:fundder/profileWidgets/followButton.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/services/followers.dart';
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
import 'package:cached_network_image/cached_network_image.dart';
import 'routes/FadeTransition.dart';
import 'messaging/chat_room.dart';

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
  List<Post> authorPostList;
  List<Post> likedPostList;
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  final AuthService _auth = AuthService();

  TabController _tabController;
  String _username = "Username";
  String _name = "Name";
  String _uid;
  String _email = "Email";
  String _profilePic;
  List<dynamic> _likesList;
  int _startIndex;
  int _lastIndex;
  bool initial = true;
  double _amountDonated = 0.00;
  int _noFollowers;
  int _noFollowing;
  String emptyMessage =
      "Looks like you haven't yet created a Fundder challenge. Press the plus icon in the bottom bar to create a new challenge.";

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
    //_retrieveUser();
    super.initState();
  }

  /*void _retrieveUser() async {
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
        //followers bookkeeping
        _noFollowing = (value.data.containsKey('noFollowing')
            ? value.data['noFollowing']
            : 0);
        _noFollowers = (value.data.containsKey('noFollowers')
            ? value.data['noFollowers']
            : 0);

        if (_profilePic == null) {
          _profilePic =
              'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/images%2Fprofile_pic_default-01.png?alt=media&token=cea24849-7590-43f8-a2ff-b630801e7283';
          DatabaseService(uid: _uid)
              .updateUserData(_email, _username, _name, _profilePic);
        }
        if (value.data['amountDonated'] != null) {
          _amountDonated = value.data['amountDonated'];
        }
      });
    });
  }*/

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user.uid != widget.uid) {
      emptyMessage = "Looks like they haven't yet created a Fundder challenge";
    }
    // print(user.uid);
    if (user == null && kIsWeb == true) {
      Future.microtask(() => Navigator.pushNamed(context, '/web/login'));
      return Scaffold(
        body: Text(
          "Redirecting",
          style: TextStyle(
              fontFamily: 'Founders Grotesk',
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
            if (snapshot != null) {
              if (snapshot.hasData && snapshot.data != []) {
                print(snapshot.data);
                _uid = widget.uid;
                if (snapshot.data['name'] != null) {
                  _name = snapshot.data["name"];
                }
                if (snapshot.data['likes'] != null) {
                  _likesList = snapshot.data["likes"];
                }
                _username = snapshot.data['username'];
                _email = snapshot.data["email"];
                if (snapshot.data["profilePic"] != null) {
                  _profilePic = snapshot.data["profilePic"];
                } else {
                  _profilePic =
                      'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/images%2Fprofile_pic_default-01.png?alt=media&token=cea24849-7590-43f8-a2ff-b630801e7283';
                }
                if (snapshot.data['amountDonated'] != null) {
                  _amountDonated = snapshot.data['amountDonated'].toDouble();
                }
                print("profile controller has data");
                _noFollowing = snapshot.data['noFollowing'] != null
                    ? snapshot.data['noFollowing']
                    : 0;
                _noFollowers = snapshot.data['noFollowers'] != null
                    ? snapshot.data['noFollowers']
                    : 0;
              }
            } else {
              print("profile controller does not have data");
            }

            return _username == null
                ? Loading()
                : Scaffold(
                    backgroundColor: Colors.grey[200],
                    appBar: kIsWeb == true
                        ? null
                        : AppBar(
                            centerTitle: true,
                            title: Text(_username),
                            actions: _uid == user.uid
                                ? <Widget>[
                                    IconButton(
                                      onPressed: () {
                                        _showOptions();
                                      },
                                      icon: Icon(AntDesign.ellipsis1),
                                    )
                                  ]
                                : <Widget>[
                                    IconButton(
                                        icon: Icon(MaterialCommunityIcons
                                            .comment_processing_outline),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              FadeRoute(
                                                  page: ChatRoom(
                                                      _uid, _username)));
                                        })
                                  ]),
                    body: Column(children: [
                      kIsWeb == true ? WebMenu(5) : Container(),
                      Expanded(
                        child: SmartRefresher(
                          enablePullDown: true,
                          enablePullUp: true,
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
                          onLoading: _onLoading,
                          child: ListView(
                              //shrinkWrap: true,
                              padding: EdgeInsets.only(top: 10),
                              children: <Widget>[
                                Container(
                                    constraints: BoxConstraints(
                                        minHeight:
                                            MediaQuery.of(context).size.height -
                                                80),
                                    decoration: new BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: new BorderRadius.all(
                                          Radius.circular(10.0),
                                        )),
                                    child: Column(children: [
                                      Container(
                                        color: Colors.white,
                                        margin: EdgeInsets.only(
                                            top: 20, bottom: 10),
                                        alignment: Alignment.center,
                                        child: Container(
                                          child: ProfilePicFromUrl(
                                              _profilePic, 90),
                                          margin: EdgeInsets.all(10.0),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          color: Colors.white,
                                          child: Text(_name),
                                        ),
                                      ),
                                      Container(
                                          color: Colors.white,
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 50, vertical: 20),
                                          height: 45,
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                  child: FlatButton(
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      alignment:
                                                          Alignment.topCenter,
                                                      child: Text(
                                                          _noFollowers
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          )),
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Text(
                                                        "Followers",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                    )),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                      context,
                                                      '/user/' +
                                                          widget.uid +
                                                          '/' +
                                                          _username +
                                                          '/followers');
                                                },
                                              )),
                                              Expanded(
                                                  child: FlatButton(
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                      alignment:
                                                          Alignment.topCenter,
                                                      child: Text(
                                                          _noFollowing
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          )),
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Text("Following",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal)),
                                                    )),
                                                  ],
                                                ),
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                      context,
                                                      '/user/' +
                                                          widget.uid +
                                                          '/' +
                                                          _username +
                                                          '/following');
                                                },
                                              )),
                                              _uid == user.uid
                                                  ? Expanded(
                                                      child: Column(
                                                      children: <Widget>[
                                                        Container(
                                                          alignment: Alignment
                                                              .topCenter,
                                                          child: Text(
                                                              "£" +
                                                                  _amountDonated
                                                                      .toStringAsFixed(
                                                                          2),
                                                              style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              )),
                                                        ),
                                                        Expanded(
                                                            child: Container(
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: Text("Raised",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal)),
                                                        )),
                                                      ],
                                                    ))
                                                  : Container()
                                            ],
                                          )),
                                      widget.uid == user.uid
                                          ? EditFundderButton(
                                              text: 'Edit Profile',
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                    context, '/account/edit');
                                              })
                                          : FutureBuilder(
                                              future: FollowersService(
                                                      uid: user.uid)
                                                  .doesXfollowY(
                                                      x: user.uid, y: _uid),
                                              builder: (context, initialState) {
                                                if (initialState
                                                            .connectionState ==
                                                        ConnectionState.done &&
                                                    initialState.data != null) {
                                                  return FollowButton(
                                                      initialState.data,
                                                      profileOwnerId: _uid,
                                                      myId: user.uid);
                                                } else {
                                                  return EditFundderButton(
                                                      text: "",
                                                      onPressed: () {});
                                                }
                                              },
                                            ),
                                      _uid != user.uid
                                          ? DefaultTabController(
                                              length: 1,
                                              initialIndex: 0,
                                              child: Column(
                                                children: [
                                                  TabBar(
                                                    onTap: (index) {},
                                                    tabs: [
                                                      Tab(text: 'Posts'),
                                                    ],
                                                  ),
                                                  _profileView(user.uid, 0),
                                                ],
                                              ),
                                            )
                                          : DefaultTabController(
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
                                                    _profileView(user.uid, 0),
                                                    _profileView(user.uid, 1)
                                                  ][_tabController.index]
                                                ],
                                              ),
                                            )
                                    ]))
                              ]),
                        ),
                      ),
                    ]),
                  );
          });
    }
  }

  Widget _profileView(String uid, int tabIndex) {
    //LikesService likesService = LikesService(uid: uid);
    List<Post> postList;
    if (tabIndex == 0 && authorPostList != null) {
      postList = authorPostList;
    } else if (tabIndex == 1 && likedPostList != null) {
      postList = likedPostList;
    }

    return Container(
        child: ListView.separated(
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                color: Colors.grey,
                height: 0,
                thickness: 0.3,
                indent: 20,
                endIndent: 0,
              );
            },
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.only(bottom: 10),
            itemCount:
                postList != null && postList.length != 0 ? postList.length : 1,
            itemBuilder: (BuildContext context, int index) {
              if (postList == null || postList.length == 0) {
                return Center(
                  child: Container(
                      padding: EdgeInsets.only(top: 40),
                      child: Column(children: [
                        Icon(
                          tabIndex == 0 ? AntDesign.meh : AntDesign.hearto,
                          color: Colors.grey,
                          size: MediaQuery.of(context).size.width / 8,
                        ),
                        Container(
                            margin: EdgeInsets.only(
                                top: 30, left: 40, right: 40, bottom: 20),
                            child: Text(
                              tabIndex == 0
                                  ? emptyMessage
                                  : "Looks like you haven't liked any posts yet",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontFamily: 'Founders Grotesk'),
                            )),
                      ])),
                );
              } else {
                Post post = postList[index];
                return Container(
                    decoration: new BoxDecoration(
                      color: Colors.white,
                      borderRadius: index == postList.length - 1
                          ? BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                            )
                          : BorderRadius.only(
                              bottomLeft: Radius.circular(0.0),
                              bottomRight: Radius.circular(0.0),
                            ),
                    ),
                    child: ListTile(
                      leading: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                            height: 60,
                            child: ClipRRect(
                              borderRadius: new BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0),
                              ),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl:
                                    post.imageUrl != null ? post.imageUrl : "",
                                placeholder: (context, url) => Loading(),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[100],
                                ),
                              ),
                            )),
                      ),
                      title: Text(
                        post.title,
                        style: TextStyle(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        post.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        post.status == 'done'
                            ? Icon(
                                Ionicons.ios_checkmark_circle,
                                color: HexColor('ff6b6c'),
                              )
                            : Container(width: 0),
                        post.author != uid
                            ? Container(width: 0)
                            : FlatButton(
                                onPressed: () {
                                  print('button pressed');
                                  _showDeleteDialog(post);
                                },
                                child: Text('Delete',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    )),
                              ),
                      ]),
                      onTap: () {
                        print("Going onto view post from activity yayy");
                        Navigator.pushNamed(context, '/post/${post.id}');
                      },
                    ));
              }
            }));
  }

  Future<void> _showDeleteDialog(Post post) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Post?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Once you delete this post, all the money donated will be refunded unless you have uploaded proof of challenge completion. This cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Firestore.instance
                    .collection('posts')
                    .document(post.id)
                    .delete()
                    .then((value) {
                  Navigator.of(context).pop();
                  initial = true;
                  _onRefresh();
                });
              },
            ),
            FlatButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _onRefresh() async {
    // monitor network fetch
    loadingTimestamp = Timestamp.now();
    List<Post> futurePost;
    if (_tabController.index == 0 || initial == true) {
      futurePost = await DatabaseService().authorPosts(widget.uid);
      if (futurePost != null) {
        if (futurePost.isEmpty == false) {
          authorPostList = futurePost;
          Post post = futurePost.last;
          print('postList' + authorPostList.toString());
          loadingTimestamp = post.timestamp;
        } else {
          authorPostList = [];
        }
      } else {
        authorPostList = [];
      }
    }
    if ((_tabController.index == 1 || initial == true) &&
        _likesList != null &&
        _likesList != [] &&
        _likesList.isEmpty == false) {
      if (_likesList.length > 10) {
        _startIndex = _likesList.length - 10;
        _lastIndex = _likesList.length;
      } else {
        _startIndex = 0;
        _lastIndex = _likesList.length;
      }
      print("startIndex1:" + _startIndex.toString());
      print("lastIndex1:" + _lastIndex.toString());
      futurePost = await DatabaseService().likedPosts(widget.uid,
          _likesList.sublist(_startIndex, _lastIndex).reversed.toList());
      futurePost = futurePost.reversed.toList();
      _lastIndex = _startIndex;
      if (_startIndex > 10) {
        _startIndex = _startIndex - 10;
      } else {
        _startIndex = 0;
      }
      print("startIndex2:" + _startIndex.toString());
      print("lastIndex2:" + _lastIndex.toString());
      if (futurePost != null) {
        if (futurePost.isEmpty == false) {
          likedPostList = futurePost;
          Post post = futurePost.last;
          print('postList' + likedPostList.toString());
          loadingTimestamp = post.timestamp;
        }
      }
    }
    if (_likesList == null || _likesList == [] || _likesList.isEmpty == true) {
      likedPostList = [];
    }
    if (mounted) setState(() {});
    // if failed,use refreshFailed()
    initial = false;
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    if (_tabController.index == 1 &&
        _startIndex != _lastIndex &&
        _likesList != null) {
      List<Post> futurePost;
      futurePost = await DatabaseService().likedPosts(widget.uid,
          _likesList.sublist(_startIndex, _lastIndex).reversed.toList());
      futurePost = futurePost.reversed.toList();
      _lastIndex = _startIndex;
      if (_startIndex > 10) {
        _startIndex = _startIndex - 10;
      } else {
        _startIndex = 0;
      }
      if (futurePost != null) {
        if (futurePost.isEmpty == false) {
          likedPostList.addAll(futurePost);
          Post post = futurePost.last;
          print('postList' + likedPostList.toString());
          loadingTimestamp = post.timestamp;
        }
      }
      if (mounted) setState(() {});
      // if failed,use refreshFailed()
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
      _refreshController.loadComplete();
    }
  }

  void _showOptions() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ProfileActions();
        });
  }
}
