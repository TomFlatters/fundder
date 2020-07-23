import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'models/post.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'feed.dart';
import 'package:flutter/cupertino.dart';
import 'helper_classes.dart';
import 'services/database.dart';
import 'models/post.dart';

// This class adds the refresh indicator to feeds not in the profile

class FeedWrapper extends StatefulWidget {
  @override
  _FeedWrapperState createState() => _FeedWrapperState();

  final String feedChoice;
  final String identifier;
  final String status;
  FeedWrapper(
    this.feedChoice,
    this.identifier,
    this.status,
  );
}

class _FeedWrapperState extends State<FeedWrapper> {
  int limit = 3;
  Timestamp loadingTimestamp;
  List<List<Post>> postList;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  void _onRefresh() async {
    // monitor network fetch
    loadingTimestamp = Timestamp.now();
    List<Post> futurePost = await DatabaseService()
        .refreshPosts(widget.status, limit, loadingTimestamp);
    postList = [futurePost];
    Post post = futurePost.last;
    print('postList' + postList.toString());
    loadingTimestamp = post.timestamp;
    if (mounted) setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch

    List<Post> futurePost = await DatabaseService()
        .refreshPosts(widget.status, limit, loadingTimestamp);
    if (futurePost != null) {
      if (futurePost.isEmpty == false) {
        print('futurePost' + futurePost.toString());
        postList.add(futurePost);
        Post post = futurePost.last;
        loadingTimestamp = post.timestamp;
      }
    }
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
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
        child: postList == null
            ? Container()
            : ListView.builder(
                itemBuilder: (c, i) => FeedView(widget.feedChoice,
                    widget.identifier, HexColor('ff6b6c'), postList[i]),
                itemCount: postList.length,
              ),
      ),
    );
  }
}
