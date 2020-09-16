import 'package:flutter/material.dart';
import '../helper_classes.dart';
import '../shared/loading.dart';
import 'package:fundder/services/likes.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';

class ViewLikers extends StatefulWidget {
  @override
  _ViewLikersState createState() => _ViewLikersState();

  final String postId;
  ViewLikers({this.postId});
}

class _ViewLikersState extends State<ViewLikers> {
  List<Map> likersList = [];
  bool firstLoadDone = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  TabController _tabController;

  @override
  void initState() {
    _getLists();
    super.initState();
  }

  void _getLists() async {
    likersList =
        await LikesService(uid: '123').unamesOfPostLikers(widget.postId);
    _refreshController.refreshCompleted();
    if (mounted)
      setState(() {
        firstLoadDone = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Likes'),
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
            : likersList == null
                ? Text('No likers')
                : SmartRefresher(
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
                      itemCount: likersList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: ProfilePic(likersList[index]['uid'], 40),
                          title: Text(likersList[index]['username']),
                          onTap: () {
                            print('/user/' + likersList[index]['uid']);
                            Navigator.pushNamed(
                                context, '/user/' + likersList[index]['uid']);
                          },
                        );
                      },
                    )));
  }
}
