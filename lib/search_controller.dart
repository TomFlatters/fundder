import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_pages/web_menu.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchController extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
  SearchController();
}

class _SearchState extends State<SearchController>
    with SingleTickerProviderStateMixin {
  String uid = '123';
  TabController _tabController;
  final SearchBarController<User> _searchBarController = SearchBarController();
  final List searchType = ["#", "users: "];
  SearchBar<User> searchBar;
  final List trending = ['trending 1', 'trending 2', 'trending 3'];

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  _handleTabSelection() {
    setState(() {});
    _searchBarController.replayLastSearch();
    print("called");
  }

  // Call search function here. search is the term to be searched.
  Future<List<User>> search(String search) async {
    //await Future.delayed(Duration(seconds: 2));
    return DatabaseService(uid: uid).usersContainingString(search);
    /*return new StreamBuilder(
        stream: DatabaseService(uid: user.uid).donePosts, builder: (context, snapshot) {
          return ListView.separated(
              physics: physics,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 10.0),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Post postData = snapshot.data[index];
        });*/
  }

  Widget _trendingList() {
    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 10.0),
      itemCount: 1,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                'Trending',
                textAlign: TextAlign.left,
              ),
            ),
            _sectionComponents()
          ],
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 10,
        );
      },
    );
  }

  Widget _sectionComponents() {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 10.0),
      itemCount: trending.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: _decideLeading(),
          title: Text(trending[index]),
          subtitle: Text(trending[index]),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 10,
        );
      },
    );
  }

  Widget _decideLeading() {
    if (_tabController.index == 0) {
      return null;
    } else {
      return CircleAvatar(
        radius: 20.0,
        backgroundImage: NetworkImage("https://i.imgur.com/BoN9kdC.png"),
        backgroundColor: Colors.transparent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
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
      return Scaffold(
        body: SafeArea(
          child: Column(children: [
            kIsWeb == true ? WebMenu(2) : Container(),
            Expanded(
              child: SearchBar<User>(
                searchBarPadding: EdgeInsets.symmetric(horizontal: 20),
                searchBarController: _searchBarController,
                header: DefaultTabController(
                  length: 2,
                  initialIndex: 0,
                  child: TabBar(
                    tabs: [Tab(text: 'Tags'), Tab(text: 'Users')],
                    controller: _tabController,
                  ),
                ),
                hintText: 'search accounts',
                onSearch: search,
                minimumChars: 0,
                onItemFound: (User user, int index) {
                  return ListTile(
                    leading: _decideLeading(),
                    title: Text(user.username),
                    //subtitle: Text(post.description),
                  );
                },

                //suggestions: [Post('previous 1','previous 1'),Post('previous 2','previous 2'),Post('previous 3','previous 3')],

                emptyWidget: _trendingList(),

                /*buildSuggestion: (Post post, int index) {
                return ListTile(
                  leading: _decideLeading(),
                  title: Text(post.title),
                  subtitle: Text(post.description),
                );
              },*/
              ),
            ),
          ]),
        ),
      );
    }
  }
}
