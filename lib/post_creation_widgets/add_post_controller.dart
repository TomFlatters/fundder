import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/models/charity.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/choose_privacy.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/image_upload.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/description_input.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/title_input.dart';
import 'package:fundder/post_creation_widgets/screens/1st_addpost_screen.dart';
import 'package:fundder/post_creation_widgets/screens/charity_list_screen.dart';
import 'package:fundder/post_creation_widgets/screens/hashtag_adding_screen.dart';
import 'package:fundder/post_creation_widgets/screens/screen_interface.dart';
import 'package:fundder/services/database.dart';
import 'package:provider/provider.dart';
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

/**UI for adding a post */

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  int _currentScreen = 0;

  CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
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
                        })),
          actions: [
            (_currentScreen < 2) ? _createNextButton() : _createPreviewButton(),
          ],
        ),
        body: MultiProvider(
          providers: [
            Provider<DescriptionInputStateManager>(
              create: (_) => DescriptionInputStateManager(),
            ),
            Provider<TitleInputStateManager>(
              create: (_) => TitleInputStateManager(),
            )
          ],
          child: Builder(
            builder: (context) => CarouselSlider(
              carouselController: _carouselController,
              items: [
                FirstAddPostScreen(),
                CharitySelectionScreen(),
                HashtaggingScreen()
              ],
              options: CarouselOptions(
                onPageChanged: (index, reason) {
                  FocusScope.of(context).unfocus();
                  if (mounted) {
                    setState(() {
                      _currentScreen = index;
                    });
                  }
                },
                enableInfiniteScroll: false,
                height: height,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                // autoPlay: false,
              ),
            ),
          ),
        ));
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

  _createPreviewButton() {
    return FlatButton(
      child: Text("Preview",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      onPressed: () {
        print("Preview button pressed on AddPost");
      },
    );
  }
}

/*
class AddPost extends StatelessWidget {
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
  bool isPrivate;
  List selectedFollowers = [];
  User user;
  bool _submitting = false;
  int _current = 0;
  CarouselController _carouselController = CarouselController();
  double aspectRatio;
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

  // The type of challenge: 0 = for yourself, 1 = for someone else
  int selected = -1;
  final List<String> whoDoes = <String>['Myself', 'Someone Else'];
  final List<String> subWho = <String>[
    'Raise money for your own challenge',
    'Will be public and anyone will be able to accept the challenge. This appears in the "Do" tab in the Feed'
  ];

  @override
  void initState() {
    // _retrieveUser();
    this.user = widget.user;
    this.isPrivate = widget.user.isPrivate;
    _loadCharityList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if ((imageFile == null && selected == 1) ||
        title == "" ||
        subtitle == "" ||
        charity == -1 ||
        (targetAmount == "0.00" && whoDoes[selected] == "Myself") ||
        hashtags.length < 2 ||
        (double.parse(targetAmount) < 2 && whoDoes[selected] == "Myself")) {
      canMoveToPreview = false;
    } else {
      canMoveToPreview = true;
    }
    return _submitting == true
        ? Loading()
        : Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: Text("Create Fundder"),
                actions: <Widget>[
                  new FlatButton(
                    child: (selected == 0 && _current == 5 ||
                            selected == 1 && _current == 4)
                        ? Text('Preview',
                            style: TextStyle(fontWeight: FontWeight.bold))
                        : (selected == 0 && _current == 6 ||
                                selected == 1 && _current == 5)
                            ? Text('Submit',
                                style: TextStyle(fontWeight: FontWeight.bold))
                            : selected != -1
                                ? Text('Next',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))
                                : null,
                    onPressed: (selected == 0 && _current == 6 ||
                            selected == 1 && _current == 5)
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
                                            _pushItem(downloadUrl, user)
                                          });
                                }
                              } else {
                                if (selected == 0) {
                                  _pushItem(null, user);
                                } else {
                                  DialogManager().createDialog(
                                      'Error',
                                      "'Do' feed challenges require an image",
                                      context);
                                  setState(() {
                                    _submitting = false;
                                  });
                                }
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

                            if (selected != -1) {
                              if (!((selected == 0 && _current == 5 ||
                                      selected == 1 && _current == 4) &&
                                  canMoveToPreview == false)) {
                                _carouselController.nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.linear);
                              } else if (title == "") {
                                DialogManager().createDialog(
                                  'Error',
                                  'You have not chosen a title',
                                  context,
                                );
                              } else if (subtitle == "") {
                                DialogManager().createDialog(
                                  'Error',
                                  'You have not written a description for the challenge',
                                  context,
                                );
                              } else if (double.parse(targetAmount) < 2 &&
                                  whoDoes[selected] == "Myself") {
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
                                  'Error',
                                  "'Do' feed challenges require an image",
                                  context,
                                );
                              } else {
                                DialogManager().createDialog(
                                  'Error',
                                  'You have not filled all the required fields',
                                  context,
                                );
                              }
                            } else {
                              DialogManager().createDialog(
                                'Error',
                                "You need to choose who you'd like to do the challenge",
                                context,
                              );
                            }
                          },
                  )
                ],
                leading: Container(
                    width: 100,
                    child: IconButton(
                        icon: _current == 0
                            ? Icon(Icons.close)
                            : Icon(Icons.arrow_back),
                        onPressed: _current == 0
                            ? () {
                                Navigator.of(context).pop(null);
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
                  items: selected == 0
                      ? canMoveToPreview == true
                          // If fund feed and all fields filled
                          ? [
                              _choosePerson(),
                              _defineDescriptionSelf(),
                              _chooseCharity(),
                              _setHashtags(),
                              _imageUpload(),
                              _selectPrivacy(this.isPrivate,
                                  _onPrivacySettingChanged, _limitVisibility),
                              _postPreview()
                            ]
                          // If fund feed and not all fields filled
                          : [
                              _choosePerson(),
                              _defineDescriptionSelf(),
                              _chooseCharity(),
                              _setHashtags(),
                              _imageUpload(),
                              _selectPrivacy(this.isPrivate,
                                  _onPrivacySettingChanged, _limitVisibility),
                            ]
                      : selected == 1
                          ? canMoveToPreview == true
                              // If do feed and all fields filled
                              ? [
                                  _choosePerson(),
                                  _defineDescriptionOthers(),
                                  _chooseCharity(),
                                  _setHashtags(),
                                  _imageUpload(),
                                  _postPreview()
                                ]
                              // If fund feed and not all fields filled
                              : [
                                  _choosePerson(),
                                  _defineDescriptionOthers(),
                                  _chooseCharity(),
                                  _setHashtags(),
                                  _imageUpload()
                                ]
                          : [
                              _choosePerson(),
                            ],
                );
              },
            ),
          );
  }

  void _onPrivacySettingChanged(newVal) {
    setState(() {
      isPrivate = newVal;
      if (newVal == false) {
        selectedFollowers = [];
      }
    });
  }

  void _limitVisibility(uids) {
    print("setting state and limiting visibility....");
    setState(() {
      isPrivate = true;
      this.selectedFollowers = uids;
    });
  }

  Widget _selectPrivacy(
      isPrivate, Function onPrivacySettingChanged, Function limitVisibility) {
    return PrivacySelection(
        onPrivacySettingChanged: onPrivacySettingChanged,
        limitVisibility: limitVisibility,
        isPrivate: isPrivate,
        selectedFollowers: this.selectedFollowers);
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
    if (title == "" ||
        subtitle == "" ||
        charity == -1 ||
        (targetAmount == "0.00" && whoDoes[selected] == "Myself") ||
        hashtags.length < 2) {
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
      if (double.parse(targetAmount) < 2 && whoDoes[selected] == "Myself") {
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
      } else {
        if (whoDoes[selected] == "Myself") {
          DatabaseService(uid: user.uid)
              .uploadPost(new Post(
                  selectedPrivateViewers: this.selectedFollowers,
                  isPrivate: this.isPrivate,
                  title: title.toString().trimRight(),
                  subtitle: subtitle.toString().trimRight(),
                  author: user.uid,
                  authorUsername: user.username,
                  charity: charities[charity].id,
                  noLikes: 0,
                  noComments: 0,
                  timestamp: DateTime.now(),
                  moneyRaised: 0,
                  targetAmount: targetAmount.toString(),
                  imageUrl: downloadUrl,
                  status: 'fund',
                  aspectRatio: aspectRatio,
                  hashtags: hashtags,
                  charityLogo: charities[charity].image))
              .then((postId) => {
                    if (postId == null)
                      {
                        if (mounted)
                          {
                            setState(() {
                              _submitting = false;
                            })
                          }
                      }
                    else
                      {
                        print("The doc id is " +
                            postId
                                .toString()
                                .substring(1, postId.toString().length - 1)),
                        HashtagsService(uid: user.uid)
                            .addHashtag(postId.toString(), hashtags),
                        Navigator.pushReplacementNamed(
                            context,
                            '/sharePost/' +
                                postId
                                    .toString()
                                    .substring(1, postId.toString().length - 1))
                      } //the substring is very important as postId.toString() is in brackets
                  });
        } else {
          // Create a template
          DatabaseService(uid: user.uid)
              .uploadTemplate(new Template(
                  title: title.toString(),
                  subtitle: subtitle.toString(),
                  author: user.uid,
                  authorUsername: user.username,
                  charity: charities[charity].id,
                  likes: [],
                  comments: {},
                  timestamp: DateTime.now(),
                  moneyRaised: 0,
                  targetAmount: targetAmount.toString(),
                  imageUrl: downloadUrl,
                  whoDoes: whoDoes[selected].toString(),
                  acceptedBy: [],
                  completedBy: [],
                  aspectRatio: aspectRatio,
                  hashtags: hashtags,
                  active: true,
                  charityLogo: charities[charity].image))
              .then((templateId) => {
                    // if the post is successfully added, view the post
                    Navigator.pushReplacementNamed(
                        context, '/challenge/' + templateId.toString())
                  });
        }
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
}

*/
