import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'package:fundder/services/followers.dart';
import 'helper_classes.dart';
import 'shared/loading.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';

class ViewFollowers extends StatefulWidget {
  @override
  _ViewFollowersState createState() => _ViewFollowersState();

  final String uid;
  ViewFollowers({this.uid});
}

class _ViewFollowersState extends State<ViewFollowers>
    with SingleTickerProviderStateMixin {
  List<Map> followersList = [];
  List<Map> followingList = [];
  bool firstLoadDone = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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
    _getLists();
    super.initState();
  }

  void _getLists() async {
    followingList =
        await GeneralFollowerServices.unamesFollowedByUser(widget.uid);
    followersList =
        await GeneralFollowerServices.unamesFollowingUser(widget.uid);
    _refreshController.refreshCompleted();
    setState(() {
      firstLoadDone = true;
    });
  }

  _handleTabSelection() {
    setState(() {});
    print("called");
  }

  @override
  Widget build(BuildContext context) {
    List usedList = [];
    if (_tabController.index == 0) {
      usedList = followersList;
    } else {
      usedList = followingList;
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("View Followers"),
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
                        onRefresh: _getLists,
                        child: ListView.builder(
                          itemCount: usedList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              leading: ProfilePic(usedList[index]['uid'], 40),
                              title: Text(usedList[index]['username']),
                              onTap: () {
                                print('/user/' + usedList[index]['uid']);
                                Navigator.pushNamed(
                                    context, '/user/' + usedList[index]['uid']);
                              },
                            );
                          },
                        ))),
              ]));
  }
}
