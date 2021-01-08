import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/models/post.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/image_upload.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/description_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/hashtag_input_field.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/isPrivate_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/media_upload.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/money_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/title_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/which_charity_input.dart';
import 'package:fundder/post_creation_widgets/screens/1st_addpost_screen.dart';
import 'package:fundder/post_creation_widgets/screens/charity_list_screen.dart';
import 'package:fundder/post_creation_widgets/screens/hashtag_adding_screen.dart';
import 'package:fundder/services/database.dart';
import 'package:fundder/services/hashtags.dart';
import 'package:fundder/shared/loading.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'creation_tiles/post_preview.dart';
import 'creation_tiles/tile_widgets/image_view.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';

/**UI for adding a post */

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  /**Keeps track of the index of the screens the carousel is currently displaying */
  int _currentScreen = 0;
  /**Number of screens in which the user can enter details about their post */
  final int noOfInputScreens = 3;
  /**Returns true if UI is displaying a preview of the post the user has made.
   * All valdiation checks will have been passed by this point.
   */
  bool get _inPreview {
    return (_currentScreen > noOfInputScreens - 1);
  }

  List<Widget> _screens = [
    FirstAddPostScreen(),
    CharitySelectionScreen(),
    HashtaggingScreen()
  ];

  CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return MultiProvider(
        //minimise this list in IDE for readability
        providers: [
          Provider<DescriptionInputStateManager>(
            create: (_) => DescriptionInputStateManager(),
          ),
          Provider<TitleInputStateManager>(
            create: (_) => TitleInputStateManager(),
          ),
          ChangeNotifierProvider<MediaStateManager>(
              create: (_) => MediaStateManager()),
          Provider<MoneyInputStateManager>(
            create: (_) => MoneyInputStateManager(),
          ),
          ChangeNotifierProvider<CharitySelectionStateManager>(
            create: (_) => CharitySelectionStateManager(),
          ),
          Provider<HashtagsStateManager>(
            create: (_) => HashtagsStateManager(),
          ),
          Provider<PrivateStatusStateManager>(
            create: (_) => PrivateStatusStateManager(),
          )
        ],
        child: Builder(
            builder: (context) => Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    title: Text("Create Fundder"),
                    leading: Container(
                        width: 100,
                        child: IconButton(
                            icon: _currentScreen == 0
                                ? Icon(Icons.close)
                                : Icon(Icons.arrow_back),
                            onPressed: _currentScreen == 0
                                ? () {
                                    Navigator.of(context).pop(null);
                                  }
                                : () {
                                    _carouselController.previousPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.linear);
                                    if (_inPreview) {
                                      setState(() {
                                        _screens.removeLast();
                                      });
                                    }
                                  })),
                    actions: [
                      (_currentScreen < noOfInputScreens - 1)
                          ? _createNextButton()
                          : (!_inPreview)
                              ? _createPreviewButton(context)
                              : _createUploadButton(context),
                    ],
                  ),
                  body: CarouselSlider(
                    carouselController: _carouselController,
                    items: _screens,
                    options: CarouselOptions(
                      onPageChanged: (index, reason) {
                        FocusScope.of(context).unfocus();
                        if (mounted) {
                          if (_inPreview) {
                            setState(() {
                              _screens.removeLast();
                              _currentScreen = _screens.length - 1;
                            });
                          } else {
                            setState(() {
                              _currentScreen = index;
                            });
                          }
                        }
                      },
                      enableInfiniteScroll: false,
                      height: height,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      // autoPlay: false,
                    ),
                  ),
                )));
  }

  _createNextButton() {
    return FlatButton(
      child: Text("Next",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      onPressed: () {
        _carouselController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.linear);
      },
    );
  }

  _createPreviewButton(context) {
    final descriptionState =
        Provider.of<DescriptionInputStateManager>(context, listen: false);
    final titleState =
        Provider.of<TitleInputStateManager>(context, listen: false);
    final targetAmountState =
        Provider.of<MoneyInputStateManager>(context, listen: false);
    final mediaState = Provider.of<MediaStateManager>(context, listen: false);
    final charityState =
        Provider.of<CharitySelectionStateManager>(context, listen: false);
    final hashtagState =
        Provider.of<HashtagsStateManager>(context, listen: false);
    final privateStatusState =
        Provider.of<PrivateStatusStateManager>(context, listen: false);

    List validityCheckers = [
      descriptionState,
      titleState,
      targetAmountState,
      mediaState,
      charityState,
      hashtagState
    ];
    return FlatButton(
      //minimise for code readability
      child: Text("Preview",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      onPressed: () {
        //will leverage the validity checker of each state from the provider
        //'listen' parameter will be set to false
        //if everything is deemed valid then it'll go to postPreview

        bool areInputsValid = true;
        for (var state in validityCheckers) {
          areInputsValid = state.isInputValid && areInputsValid;
          if (!areInputsValid) {
            state.createErrorDialog(context);
            break;
          }
        }
        if (areInputsValid) {
          //all inputs are clearly valid. Execute code to move onto preview.
          print("Can Move to Preview");
          User _user = Provider.of<User>(context);
          final height = (MediaQuery.of(context).size.height) * 2 / 5;
          final width = MediaQuery.of(context).size.width;

          var postPreview = FutureBuilder(
              future: Firestore.instance
                  .collection('users')
                  .document(_user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var value = snapshot.data;
                  bool isPrivate = (value.data["isPrivate"] == null)
                      ? false
                      : value.data["isPrivate"];
                  privateStatusState.updateValue(isPrivate);

                  //this is terrible easter egg coding from me but life moves on I suppose
                  privateStatusState.setUsername(value.data['username']);
                  User user = User(
                      isPrivate: isPrivate,
                      uid: _user.uid,
                      name: value.data["name"],
                      username: value.data['username'],
                      email: value.data['email'],
                      profilePic: value.data["profilePic"]);

                  return PostPreview(
                      charity:
                          charityState.charityList[charityState.currentValue],
                      authorUid: user != null ? user.uid : '',
                      authorUsername: user != null ? user.username : '',
                      imageView: ImageView(
                        imageFile: mediaState.imageFile,
                        height: height,
                        width: width,
                      ),
                      title: titleState.currentValue,
                      subtitle: descriptionState.currentValue,
                      selected: 0, //to make compatible with legacy code
                      targetAmount: targetAmountState.currentValue,
                      hashtags: hashtagState.currentValue);
                } else {
                  return Loading();
                }
              });

          setState(() {
            _screens.add(postPreview);
          });
          _carouselController.nextPage(
              duration: Duration(milliseconds: 300), curve: Curves.linear);
        }
      },
    );
  }

  _createUploadButton(context) {
    return FlatButton(
      child: Text("Post",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      onPressed: () {
        //Navigator.of(context).pop(null);
        showDialog(
          context: context,
          builder: (_) => FutureProgressDialog(_uploadPost(context),
              message: Text("Uploading...")),
        );
      },
    );
  }

/**Returns the postId of the post on successful upload */
  Future _uploadPost(context) async {
    //getting all the relevant states
    final descriptionState =
        Provider.of<DescriptionInputStateManager>(context, listen: false);
    final titleState =
        Provider.of<TitleInputStateManager>(context, listen: false);
    final targetAmountState =
        Provider.of<MoneyInputStateManager>(context, listen: false);
    final mediaState = Provider.of<MediaStateManager>(context, listen: false);
    final charityState =
        Provider.of<CharitySelectionStateManager>(context, listen: false);
    final hashtagState =
        Provider.of<HashtagsStateManager>(context, listen: false);
    final privateStatusState =
        Provider.of<PrivateStatusStateManager>(context, listen: false);
    final user = Provider.of<User>(context, listen: false);

    final String fileLocation =
        user.uid + "/" + DateTime.now().microsecondsSinceEpoch.toString();
    print("uploading image");
    String downloadUrl = await DatabaseService(uid: user.uid)
        .uploadImage(File(mediaState.imageFile.path), fileLocation);
    print("uploading post now");
    DatabaseService(uid: user.uid)
        .uploadPost(new Post(
            isPrivate: privateStatusState.currentValue,
            title: titleState.currentValue.trimRight(),
            subtitle: descriptionState.currentValue.toString().trimRight(),
            author: user.uid,
            authorUsername: privateStatusState.authorUsername,
            charity: charityState.charityList[charityState.currentValue].id,
            noLikes: 0,
            noComments: 0,
            timestamp: DateTime.now(),
            moneyRaised: 0,
            targetAmount: targetAmountState.currentValue.toString(),
            imageUrl: downloadUrl,
            status: 'fund',
            aspectRatio: mediaState.aspectRatio,
            hashtags: hashtagState.currentValue,
            charityLogo:
                charityState.charityList[charityState.currentValue].image))
        .then((postId) => {
              print("The doc id is " +
                  postId.toString().substring(1, postId.toString().length - 1)),
              HashtagsService(uid: user.uid)
                  .addHashtag(postId.toString(), hashtagState.currentValue),
              Navigator.pushReplacementNamed(
                  context,
                  '/sharePost/' +
                      postId
                          .toString()
                          .substring(1, postId.toString().length - 1)),
              print("Upload complete...")
            }); //the substring is very important as postId.toString() is in brackets
  }
}
