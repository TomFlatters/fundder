import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'models/post.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'feed.dart';
import 'package:flutter/cupertino.dart';
import 'helper_classes.dart';
import 'services/database.dart';
import 'shared/loading.dart';

// This class adds the refresh indicator to feeds not in the profile

// The reason that every load creates a new feedview into a list is to make the
// scrolling more seamless with no realoding of video controllers previously made

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
  bool initialLoadComplete = false;
  int limit = 5;
  Timestamp loadingTimestamp;
  List<FeedView> postList;
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
    List<Post> futurePost;
    if (widget.status == 'hashtag') {
      futurePost = await DatabaseService()
          .refreshHashtag(widget.identifier, limit, loadingTimestamp);
    } else {
      futurePost = await DatabaseService()
          .refreshPosts(widget.status, limit, loadingTimestamp);
    }
    postList = [
      FeedView(futurePost, () {
        _onRefresh();
      }, widget.status == 'hashtag' ? widget.identifier : null)
    ];
    if (futurePost != null) {
      if (futurePost.isEmpty == false) {
        Post post = futurePost.last;
        print('postList' + postList.toString());
        loadingTimestamp = post.timestamp;
      }
    }
    initialLoadComplete = true;
    if (mounted) setState(() {});
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch

    List<Post> futurePost;
    if (widget.status == 'hashtag') {
      futurePost = await DatabaseService()
          .refreshHashtag(widget.identifier, limit, loadingTimestamp);
    } else {
      futurePost = await DatabaseService()
          .refreshPosts(widget.status, limit, loadingTimestamp);
    }
    if (futurePost != null) {
      if (futurePost.isEmpty == false) {
        print('futurePost' + futurePost.toString());
        postList.add(FeedView(futurePost, () {
          _onRefresh();
        }, widget.status == 'hashtag' ? widget.identifier : null));
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
      backgroundColor: Colors.grey[200],
      body: initialLoadComplete == false
          ? Loading()
          : SmartRefresher(
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
                      itemBuilder: (c, i) => postList[i],
                      itemCount: postList.length,
                    ),
            ),
    );
  }
}
