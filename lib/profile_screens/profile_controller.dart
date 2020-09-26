import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/profileWidgets/followButton.dart';
import 'package:fundder/services/auth.dart';
import 'package:fundder/services/followers.dart';
import 'profile_actions_view.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/models/user.dart';
import 'package:fundder/services/database.dart';
import 'package:provider/provider.dart';
import '../helper_classes.dart';
import '../models/user.dart';
import '../shared/loading.dart';
import '../global_widgets/buttons.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fundder/global_widgets/dialogs.dart';

class ProfileController extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();

  final User user;
  ProfileController({@required this.user});
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

  bool checkedProfileTutorial = false;

  TabController _tabController;
  int _startIndex;
  int _lastIndex;
  bool initial = true;
  String emptyMessage =
      "Looks like you haven't yet created a Fundder challenge. Press the plus icon in the bottom bar to create a new challenge.";

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    //_retrieveUser();
    super.initState();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = Provider.of<User>(context);
    if (widget.user.uid != widget.user.uid) {
      emptyMessage = "Looks like they haven't yet created a Fundder challenge";
    }
    // print(user.uid);
    return widget.user.username == null || widget.user.name == null
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
                centerTitle: true,
                title: Text(widget.user.username),
                actions: widget.user.uid == firebaseUser.uid
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
                            icon: Icon(SimpleLineIcons.bubble),
                            onPressed: () {
                              Navigator.pushNamed(
                                  context,
                                  '/chatroom/' +
                                      widget.user.uid +
                                      '/' +
                                      widget.user.username);
                            })
                      ]),
            body: Column(children: [
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
                                    MediaQuery.of(context).size.height - 80),
                            decoration: new BoxDecoration(
                                color: Colors.white,
                                borderRadius: new BorderRadius.all(
                                  Radius.circular(10.0),
                                )),
                            child: Column(children: [
                              Container(
                                color: Colors.white,
                                margin: EdgeInsets.only(top: 20, bottom: 10),
                                alignment: Alignment.center,
                                child: Container(
                                  child: ProfilePicFromUrl(
                                      widget.user.profilePic, 90),
                                  margin: EdgeInsets.all(10.0),
                                ),
                              ),
                              Center(
                                child: Container(
                                  color: Colors.white,
                                  child: Text(widget.user.name),
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
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                  widget.user.followers == null
                                                      ? '0'
                                                      : widget.user.followers
                                                          .toString(),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                  )),
                                            ),
                                            Expanded(
                                                child: Container(
                                              alignment: Alignment.bottomCenter,
                                              child: Text(
                                                "Followers",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            )),
                                          ],
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context,
                                              '/user/' +
                                                  widget.user.uid +
                                                  '/' +
                                                  widget.user.username +
                                                  '/followers');
                                        },
                                      )),
                                      Expanded(
                                          child: FlatButton(
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              alignment: Alignment.topCenter,
                                              child: Text(
                                                  widget.user.following == null
                                                      ? '0'
                                                      : widget.user.following
                                                          .toString(),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                  )),
                                            ),
                                            Expanded(
                                                child: Container(
                                              alignment: Alignment.bottomCenter,
                                              child: Text("Following",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            )),
                                          ],
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context,
                                              '/user/' +
                                                  widget.user.uid +
                                                  '/' +
                                                  widget.user.username +
                                                  '/following');
                                        },
                                      )),
                                      widget.user.uid == firebaseUser.uid
                                          ? Expanded(
                                              child: Column(
                                              children: <Widget>[
                                                Container(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Text(
                                                      widget.user.amountDonated ==
                                                              null
                                                          ? '£0.00'
                                                          : "£" +
                                                              widget.user
                                                                  .amountDonated
                                                                  .toStringAsFixed(
                                                                      2),
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      )),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Text("Raised",
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .normal)),
                                                )),
                                              ],
                                            ))
                                          : Container()
                                    ],
                                  )),
                              widget.user.uid == firebaseUser.uid
                                  ? EditFundderButton(
                                      text: 'Edit Profile',
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/account/edit');
                                      })
                                  : FutureBuilder(
                                      future: FollowersService(
                                              uid: firebaseUser.uid)
                                          .doesXfollowY(
                                              x: firebaseUser.uid,
                                              y: widget.user.uid),
                                      builder: (context, initialState) {
                                        if (initialState.connectionState ==
                                                ConnectionState.done &&
                                            initialState.data != null) {
                                          return FollowButton(initialState.data,
                                              profileOwnerId: widget.user.uid,
                                              myId: firebaseUser.uid);
                                        } else {
                                          return EditFundderButton(
                                              text: "", onPressed: () {});
                                        }
                                      },
                                    ),
                              widget.user.uid != firebaseUser.uid
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
                                          _profileView(firebaseUser.uid, 0),
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
                                            _profileView(firebaseUser.uid, 0),
                                            _profileView(firebaseUser.uid, 1)
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
                                  DialogManager().showDeleteDialog(
                                      post, context, _onRefresh);
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

  void _onRefresh() async {
    // monitor network fetch
    loadingTimestamp = Timestamp.now();
    List<Post> futurePost;
    if (_tabController.index == 0 || initial == true) {
      futurePost = await DatabaseService().authorPosts(widget.user.uid);
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
        widget.user.likes != null &&
        widget.user.likes != [] &&
        widget.user.likes.isEmpty == false) {
      if (widget.user.likes.length > 10) {
        _startIndex = widget.user.likes.length - 10;
        _lastIndex = widget.user.likes.length;
      } else {
        _startIndex = 0;
        _lastIndex = widget.user.likes.length;
      }
      print("startIndex1:" + _startIndex.toString());
      print("lastIndex1:" + _lastIndex.toString());
      futurePost = await DatabaseService().likedPosts(widget.user.uid,
          widget.user.likes.sublist(_startIndex, _lastIndex).reversed.toList());
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
    if (widget.user.likes == null ||
        widget.user.likes == [] ||
        widget.user.likes.isEmpty == true) {
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
        widget.user.likes != null) {
      List<Post> futurePost;
      futurePost = await DatabaseService().likedPosts(widget.user.uid,
          widget.user.likes.sublist(_startIndex, _lastIndex).reversed.toList());
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
