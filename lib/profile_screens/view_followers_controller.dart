import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'package:fundder/services/followers.dart';
import '../helper_classes.dart';
import '../shared/loading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:fundder/global_widgets/user_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:fundder/models/user.dart';

class ViewFollowers extends StatefulWidget {
  @override
  _ViewFollowersState createState() => _ViewFollowersState();

  final String uid;
  final int startIndex;
  final String username;
  ViewFollowers({this.uid, @required this.startIndex, @required this.username});
}

class _ViewFollowersState extends State<ViewFollowers>
    with SingleTickerProviderStateMixin {
  List<Map> followersList = [];
  List<Map> followingList = [];
  bool firstLoadDone = false;
  TabController _tabController;
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _tabController.index = widget.startIndex;
    _getLists();
    super.initState();
  }

  void _getLists() async {
    followingList =
        await GeneralFollowerServices.unamesFollowedByUser(widget.uid);
    followersList =
        await GeneralFollowerServices.unamesFollowingUser(widget.uid);
    if (mounted)
      setState(() {
        firstLoadDone = true;
      });
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      if (mounted) setState(() {});
      print("called");
    }
  }

  @override
  Widget build(BuildContext context) {
    print('rebuilding followers');
    var user = Provider.of<User>(context);
    List usedList = [];
    if (_tabController.index == 0) {
      usedList = followersList;
    } else {
      usedList = followingList;
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.username),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(null),
            )
          ],
          leading: new Container(),
        ),
        body: firstLoadDone == false
            ? Loading()
            : Column(children: [
                Container(
                    height: 50,
                    child: TabBar(
                      tabs: [Tab(text: 'Followers'), Tab(text: 'Following')],
                      controller: _tabController,
                    )),
                Expanded(
                    child: ListView.builder(
                  itemCount: usedList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return UserListTile(
                      currentUserUid: user.uid,
                      displayUserUid: usedList[index]['uid'],
                      displayUserUsername: usedList[index]['username'],
                    );
                  },
                )),
              ]));
  }
}
