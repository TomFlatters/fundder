import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';

class Post {
  final String title;
  final String description;

  Post(this.title, this.description);
}

class SearchController extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
  SearchController();
}

class _SearchState extends State<SearchController> with SingleTickerProviderStateMixin {

  TabController _tabController;
  final SearchBarController<Post> _searchBarController = SearchBarController();
  final List searchType = ["tags","users"];
  SearchBar<Post> searchBar;

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

  Future<List<Post>> search(String search) async {
  await Future.delayed(Duration(seconds: 2));
  return List.generate(search.length, (int index) {
    return Post(
      "${searchType[_tabController.index]} : $search $index",
      "Description :$search $index",
    );
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SearchBar<Post>(
          searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
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
          onItemFound: (Post post, int index) {
            return ListTile(
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage:
                    NetworkImage("https://i.imgur.com/BoN9kdC.png"),
                backgroundColor: Colors.transparent,
              ),
              title: Text(post.title),
              subtitle: Text(post.description),
            );
          },
        ),
      ),
    );
  }
}