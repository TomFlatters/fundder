import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/challenge_friend/challengeService.dart';
import 'package:fundder/challenge_friend/screens/challenge_description.dart';
import 'package:fundder/challenge_friend/screens/challenge_preview.dart';
import 'package:fundder/challenge_friend/share_link_Screen.dart';
import 'package:fundder/models/charity.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/choose_privacy.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/image_upload.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/description_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/hashtag_input_field.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/isPrivate_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/media_upload.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/money_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/title_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/which_charity_input.dart';
import 'package:fundder/post_creation_widgets/screens/charity_list_screen.dart';
import 'package:fundder/post_creation_widgets/screens/hashtag_adding_screen.dart';
import 'package:fundder/services/database.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import '../models/user.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fundder/models/post.dart';
import 'package:fundder/models/template.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../shared/loading.dart';
import '../global_widgets/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/hashtags.dart';
import 'creation_tiles/choose_person.dart';
import 'creation_tiles/define_description_self.dart';
import 'creation_tiles/define_description_others.dart';
import 'creation_tiles/choose_charity.dart';
import 'creation_tiles/set_hashtags.dart';
import 'creation_tiles/post_preview.dart';
import 'creation_tiles/tile_widgets/image_view.dart';
import 'package:fundder/global_widgets/dialogs.dart';

class ChallengeFriend extends StatefulWidget {
  @override
  _ChallengeFriendState createState() => _ChallengeFriendState();
}

class _ChallengeFriendState extends State<ChallengeFriend> {
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
    ChallengeDescription(),
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
                    title: Text("Create Challenge"),
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
                              //because you must be in the last screen by default to be in preview
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
    print("preview button for challenges pressed");
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
        //will leverage the validity checker of each state from the provider.
        //'listen' parameter will be set to false.
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
          setState(() {
            _screens.add(ViewChallenge());
          });
          _carouselController.nextPage(
              duration: Duration(milliseconds: 300), curve: Curves.linear);
        }
      },
    );
  }

  _createUploadButton(context) {
    return FlatButton(
      child: Text("Create",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => FutureProgressDialog(makeChallenge(context),
              message: Text("Creating this challenge...")),
        );
      },
    );
  }

/**Initates the challenge creation process */
  Future makeChallenge(context) async {
    User user = Provider.of<User>(context);
    final mediaState = Provider.of<MediaStateManager>(context, listen: false);
    final String fileLocation =
        user.uid + "/" + DateTime.now().microsecondsSinceEpoch.toString();
    var downloadUrl = await DatabaseService(uid: user.uid)
        .uploadImage(File(mediaState.imageFile.path), fileLocation);
    _shareThisChallenge(downloadUrl, context);
  }

  /**Uploads challenge and return its id */
  Future<String> getChallengeDocId(downloadUrl, context) {
    ChallengeService challengeService = ChallengeService();
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
    return challengeService.uploadChallenge(
        title: titleState.currentValue,
        subtitle: descriptionState.currentValue,
        author: user.uid,
        authorUsername: privateStatusState.authorUsername,
        charity: charityState.charityList[charityState.currentValue].id,
        timestamp: Timestamp.now(),
        targetAmount: targetAmountState.currentValue.toString(),
        imageUrl: downloadUrl,
        aspectRatio: 1, //as we're only uploading an image
        hashtags: hashtagState.currentValue,
        charityLogo: charityState.charityList[charityState.currentValue].image);
  }

/**Creates a link for the challenge as well as calling 
 * getChallengeDocId to upload the challenge in the process
 */

  Future _shareThisChallenge(downloadUrl, context) async {
    final privateStatusState =
        Provider.of<PrivateStatusStateManager>(context, listen: false);
    final descriptionState =
        Provider.of<DescriptionInputStateManager>(context, listen: false);
    ChallengeService challengeService = ChallengeService();
    String challengeDocId = await getChallengeDocId(downloadUrl, context);
    Uri shortUrl =
        await challengeService.createChallengeLink(challengeDocId, downloadUrl);
    /*Share.share(
        '${privateStatusState.authorUsername} challenged you!\n ' +
            shortUrl.toString(),
        subject: descriptionState.currentValue);
    Navigator.of(context).pop();*/
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ShareLinkController(
                  link: shortUrl,
                  challengeId: challengeDocId,
                  username: privateStatusState.authorUsername,
                )));
  }
}
