import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fundder/models/charity.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/image_upload.dart';
import 'package:fundder/services/database.dart';
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

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
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
    _retrieveUser();
    _loadCharityList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final user = Provider.of<User>(context);
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
                    child: _current == 4
                        ? Text('Preview',
                            style: TextStyle(fontWeight: FontWeight.bold))
                        : _current == 5
                            ? Text('Submit',
                                style: TextStyle(fontWeight: FontWeight.bold))
                            : selected != -1
                                ? Text('Next',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))
                                : null,
                    onPressed: _current == 5
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
                                  _showErrorDialog(
                                      'You have not filled all the required fields');
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
                                  _showErrorDialog(
                                      "'Do' feed challenges require an image");
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
                              _showErrorDialog(e.toString());
                            }
                          }
                        : () {
                            /*Navigator.of(context).pushReplacement(_viewPost());*/

                            if (selected != -1) {
                              if (!(_current == 4 &&
                                  canMoveToPreview == false)) {
                                _carouselController.nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.linear);
                              } else if (title == "") {
                                _showErrorDialog('You have not chosen a title');
                              } else if (subtitle == "") {
                                _showErrorDialog(
                                    'You have not written a description for the challenge');
                              } else if (double.parse(targetAmount) < 2 &&
                                  whoDoes[selected] == "Myself") {
                                _showErrorDialog(
                                    'Minimum target fundraising amount is £2.00');
                              } else if (charity == -1) {
                                _showErrorDialog(
                                    'You have not chosen a charity');
                              } else if (hashtags.length < 2) {
                                _showErrorDialog(
                                    'You need a minimum of 2 hashtags');
                              } else if (selected == 1 && imageFile == null) {
                                _showErrorDialog(
                                    "'Do' feed challenges require an image");
                              } else {
                                _showErrorDialog(
                                    'You have not filled all the required fields');
                              }
                            } else {
                              _showErrorDialog(
                                  "You need to choose who you'd like to do the challenge");
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
                              _postPreview()
                            ]
                          // If fund feed and not all fields filled
                          : [
                              _choosePerson(),
                              _defineDescriptionSelf(),
                              _chooseCharity(),
                              _setHashtags(),
                              _imageUpload()
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
      _showErrorDialog('You have not filled all the required fields');
    } else {
      if (double.parse(targetAmount) < 2 && whoDoes[selected] == "Myself") {
        if (mounted) {
          setState(() {
            _submitting = false;
          });
        }
        _showErrorDialog('The minimum donation target amount is £2');
      } else {
        if (whoDoes[selected] == "Myself") {
          DatabaseService(uid: user.uid)
              .uploadPost(new Post(
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
                            '/post/' +
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

  Future<void> _showErrorDialog(String string) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error Creating Challenge'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(string),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // Define widgets for each of the form stages:

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
