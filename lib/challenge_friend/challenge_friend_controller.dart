import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/challenge_friend/challengeService.dart';
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
    Container(
      child: Center(child: Text("Hello world!")),
    ),
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
      },
    );
  }

  _createUploadButton(context) {
    print("Upload button for challenges pressed");
  }
}

/*
class ChallengeFriend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final contextUser = Provider.of<User>(context);
    String uid = contextUser.uid;

    return FutureBuilder(
        future: Firestore.instance.collection('users').document(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var value = snapshot.data;
            User user = User(
                isPrivate: (value.data["isPrivate"] == null)
                    ? false
                    : value.data["isPrivate"],
                uid: uid,
                name: value.data["name"],
                username: value.data['username'],
                email: value.data['email'],
                profilePic: value.data["profilePic"]);

            return AddPostWithUser(user);
          } else {
            return Loading();
          }
        });
  }
}

class AddPostWithUser extends StatefulWidget {
  final User user;
  AddPostWithUser(this.user);
  @override
  _AddPostWithUserState createState() => _AddPostWithUserState();
}

class _AddPostWithUserState extends State<AddPostWithUser> {
  User user;
  bool _submitting = false;
  int _current = 0;
  CarouselController _carouselController = CarouselController();
  double aspectRatio;

  /**canMoveToPreview has been repurposed to 'can create a challenge' */
  bool canMoveToPreview = false;

  // The image file
  PickedFile imageFile;

  // List of hashtags
  List<String> hashtags = [];

  // List of charities. If charity = -1 then no charity is selected
  List<Charity> charities;
  int charity = -1;

  // Define description variables
  String title = "";
  String subtitle = "";
  String targetAmount = '0.00';

  // The type of challenge: 0 = for yourself, 1 = for someone else, 2 for challenge a friend
  int selected = 2;

  @override
  void initState() {
    // _retrieveUser();
    this.user = widget.user;
    _loadCharityList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if ((imageFile == null) ||
        title == "" ||
        subtitle == "" ||
        charity == -1 ||
        hashtags.length < 2 ||
        (double.parse(targetAmount) < 2)) {
      canMoveToPreview = false;
    } else {
      canMoveToPreview = true;
    }
    return _submitting == true
        ? Loading()
        : Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: Text("Challenge a Friend"),
                actions: <Widget>[
                  new FlatButton(
                      child: (_current == 3)
                          ? Text('Create',
                              style: TextStyle(fontWeight: FontWeight.bold))
                          : (_current == 4)
                              ? Container()
                              : Text('Next',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: (_current == 3)
                          ? () {
                              try {
                                if (mounted) {
                                  setState(() {
                                    _submitting = true;
                                  });
                                }

                                // add image to firebase storage
                                if (imageFile != null) {
                                  if (canMoveToPreview == false) {
                                    if (mounted) {
                                      setState(() {
                                        _submitting = false;
                                      });
                                    }
                                    DialogManager().createDialog(
                                      'Error',
                                      'You have not filled all the required fields',
                                      context,
                                    );
                                  } else {
                                    print(
                                        "Have created a challenge. Now a link will be created.");
                                    final String fileLocation = user.uid +
                                        "/" +
                                        DateTime.now()
                                            .microsecondsSinceEpoch
                                            .toString();
                                    DatabaseService(uid: user.uid)
                                        .uploadImage(
                                            File(imageFile.path), fileLocation)
                                        .then((downloadUrl) => {
                                              print("Successful image upload"),
                                              print(downloadUrl),
                                              _shareThisChallenge(downloadUrl),
                                              Navigator.pop(context),
                                            });

                                    _carouselController.nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.linear);
                                  }
                                } else {
                                  DialogManager().createDialog(
                                      'Hold on...',
                                      "Spice the challenge up with an image",
                                      context);
                                  setState(() {
                                    _submitting = false;
                                  });
                                }
                              } catch (e) {
                                if (mounted) {
                                  setState(() {
                                    _submitting = false;
                                  });
                                }
                                DialogManager().createDialog(
                                  'Error',
                                  e.toString(),
                                  context,
                                );
                              }
                            }
                          : () {
                              /*Navigator.of(context).pushReplacement(_viewPost());*/
                              if (_current < 3 && canMoveToPreview == false) {
                                //basically: slide if not all info has been filled
                                _carouselController.nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.linear);
                              } else if (title == "") {
                                DialogManager().createDialog(
                                  'Hold on...',
                                  'You have not chosen a title',
                                  context,
                                );
                              } else if (subtitle == "") {
                                DialogManager().createDialog(
                                  'Error',
                                  'You have not written a description for the challenge',
                                  context,
                                );
                              } else if (double.parse(targetAmount) < 2) {
                                DialogManager().createDialog(
                                  'Error',
                                  'Minimum target fundraising amount is £2.00',
                                  context,
                                );
                              } else if (charity == -1) {
                                DialogManager().createDialog(
                                  'Error',
                                  'You have not chosen a charity',
                                  context,
                                );
                              } else if (hashtags.length < 2) {
                                DialogManager().createDialog(
                                  'Error',
                                  'You need a minimum of 2 hashtags',
                                  context,
                                );
                              } else if (selected == 1 && imageFile == null) {
                                DialogManager().createDialog(
                                  'Hold on...',
                                  "Spice the challenge up with an image",
                                  context,
                                );
                              } else {
                                DialogManager().createDialog(
                                  'Error',
                                  'You have not filled all the required fields',
                                  context,
                                );
                              }
                            })
                ],
                leading: Container(
                    width: 100,
                    child: IconButton(
                        icon: _current == 0
                            ? Icon(
                                Icons.close,
                              )
                            : Icon(Icons.arrow_back),
                        onPressed: _current == 0
                            ? () {
                                Navigator.pop(context);
                              }
                            : () {
                                _carouselController.previousPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.linear);
                              }))),
            body: Builder(
              builder: (context) {
                final double height = MediaQuery.of(context).size.height;
                return CarouselSlider(
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      onPageChanged: (index, reason) {
                        _changePage();
                        if (mounted) {
                          setState(() {
                            _current = index;
                          });
                        }
                      },
                      enableInfiniteScroll: false,
                      height: height,
                      viewportFraction: 1.0,
                      enlargeCenterPage: false,
                      // autoPlay: false,
                    ),
                    items: [
                      _defineDescriptionSelf(),
                      _chooseCharity(),
                      _setHashtags(),
                      _imageUpload(),
                    ]);
              },
            ),
          );
  }

  Widget _choosePerson() {
    return ChoosePerson(
        selected: selected, chooseSelected: _haveSelectedPerson);
  }

  Widget _defineDescriptionSelf() {
    return DefineDescriptionSelf(
      onTitleChange: _onTitleChange,
      onSubtitleChange: _onSubtitleChange,
      onMoneyChange: _onTargetAmountChange,
      nextPage: _nextPage,
      title: title,
      subtitle: subtitle,
      money: targetAmount,
    );
  }

  Widget _defineDescriptionOthers() {
    return DefineDescriptionOthers(
        onTitleChange: _onTitleChange,
        onSubtitleChange: _onSubtitleChange,
        title: title,
        subtitle: subtitle);
  }

  Widget _chooseCharity() {
    return ChooseCharity(
      charitySelected: _haveSelectedCharity,
      charities: charities,
      charity: charity,
    );
  }

  Widget _setHashtags() {
    return SetHashtags(hashtags: hashtags, onHasthagChange: _onHashtagsChanged);
  }

  Widget _postPreview() {
    return PostPreview(
      charity: charity == -1 ? Charity(id: "", image: "") : charities[charity],
      authorUid: user != null ? user.uid : '',
      authorUsername: user != null ? user.username : '',
      imageView: ImageView(
        aspectRatioChange: _changedAspectRatio,
        imageFile: imageFile,
      ),
      title: title,
      subtitle: subtitle,
      selected: selected,
      targetAmount: targetAmount,
      hashtags: hashtags,
    );
  }

  Widget _imageUpload() {
    return ImageUpload(
      selected: selected,
      aspectRatio: aspectRatio,
      aspectRatioChange: _changedAspectRatio,
      imageFileChange: _changedImageFile,
      imageFile: imageFile,
    );
  }

  void _changePage() {
    // Set state to make sure that views instantiate with the latest values
    setState(() {});
    FocusScope.of(context).unfocus();
  }

  void _retrieveUser() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection("users")
        .document(firebaseUser.uid)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          user = User(
              isPrivate: (value.data["isPrivate"] == null)
                  ? false
                  : value.data["isPrivate"],
              uid: firebaseUser.uid,
              name: value.data["name"],
              username: value.data['username'],
              email: firebaseUser.email,
              profilePic: value.data["profilePic"]);
        });
      }
    });
  }

  void _pushItem(String downloadUrl, User user) {
    // Validate form
    if (title == "" || subtitle == "" || charity == -1 || hashtags.length < 2) {
      if (mounted) {
        setState(() {
          _current = 0;
          _submitting = false;
        });
      }
      DialogManager().createDialog(
        'Error',
        'You have not filled all the required fields',
        context,
      );
    } else {
      if (double.parse(targetAmount) < 2) {
        if (mounted) {
          setState(() {
            _submitting = false;
          });
        }
        DialogManager().createDialog(
          'Error',
          'The minimum donation target amount is £2',
          context,
        );
      }
    }
  }

  void _haveSelectedPerson(int selectedPerson) {
    setState(() {
      selected = selectedPerson;
    });
    print('selected = ' + selected.toString());
    _carouselController.nextPage();
  }

  // _defineDescription state:

  void _onTitleChange(String titleInput) {
    setState(() {
      title = titleInput;
    });
    print('title = ' + title);
  }

  void _onSubtitleChange(String subtitleInput) {
    setState(() {
      subtitle = subtitleInput;
    });
    print('subtitle = ' + subtitle);
  }

  void _onTargetAmountChange(String targetAmountInput) {
    setState(() {
      targetAmount = targetAmountInput;
    });
    print('targetAmount = ' + targetAmount);
  }

  void _nextPage() {
    _carouselController.nextPage();
  }

  void _haveSelectedCharity(int selectedCharity) {
    setState(() {
      charity = selectedCharity;
    });
    print('charity = ' + charity.toString());
  }

  void _onHashtagsChanged(List<String> newHashtags) {
    setState(() {
      hashtags = newHashtags;
    });
    print('hashtags = ' + hashtags.toString());
  }

  // _chooseCharity state:

  void _loadCharityList() async {
    charities = await DatabaseService(uid: "123").getCharityNameList();
    if (mounted) {
      setState(() {});
    }
  }

  // _imageUpload state

  void _changedImageFile(PickedFile newImageFile) {
    if (mounted) {
      setState(() {
        imageFile = newImageFile;
      });
    }
  }

  void _changedAspectRatio(double newAspectRatio) {
    aspectRatio = newAspectRatio;
  }

  Widget _createShareScreen(String downloadUrl) {
    return ShareScreen(
      title: title.toString(),
      subtitle: subtitle.toString(),
      author: user.uid,
      authorUsername: user.username,
      charity: charities[charity].id,
      timestamp: Timestamp.now(),
      targetAmount: targetAmount.toString(),
      imageUrl: downloadUrl,
      aspectRatio: aspectRatio,
      hashtags: hashtags,
      charityLogo: charities[charity].image,
    );
  }

  Future _shareThisChallenge(downloadUrl) async {
    ChallengeService challengeService = ChallengeService();
    String challengeDocId = await getChallengeDocId(downloadUrl);
    Uri shortUrl =
        await challengeService.createChallengeLink(challengeDocId, downloadUrl);
    Share.share('${user.username} challenged you!\n ' + shortUrl.toString(),
        subject: this.title);
  }

  Future<String> getChallengeDocId(downloadUrl) {
    ChallengeService challengeService = ChallengeService();
    return challengeService.uploadChallenge(
        title: title,
        subtitle: subtitle,
        author: user.uid,
        authorUsername: user.username,
        charity: charities[charity].id,
        timestamp: Timestamp.now(),
        targetAmount: targetAmount,
        imageUrl: downloadUrl,
        aspectRatio: aspectRatio,
        hashtags: hashtags,
        charityLogo: charities[charity].image);
  }
}

*/
