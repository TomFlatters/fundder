import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/models/charity.dart';
import 'package:fundder/services/database.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'view_post_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:fundder/models/post.dart';
import 'package:fundder/models/template.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'shared/loading.dart';
import 'global_widgets/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/hashtags.dart';
import 'add_post_widgets/who_do_tiles.dart';
import 'add_post_widgets/charity_tiles.dart';
import 'post_widgets/postHeader.dart';
import 'post_widgets/postBody.dart';

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

  // Person who does this - selects the screens which appear next

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
    if (user == null && kIsWeb == true) {
      Future.microtask(() => Navigator.pushNamed(context, '/web/login'));
      return Scaffold(
        body: Text(
          "Redirecting",
          style: TextStyle(
              fontFamily: 'Founders Grotesk',
              fontSize: 20,
              color: Colors.black,
              decoration: null),
        ),
      );
    } else
    // This size provide us total height and width  of our screen
    {
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))
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
                                  if (titleController.text == "" ||
                                      subtitleController.text == "" ||
                                      charity == -1 ||
                                      (moneyController.text == "0.00" &&
                                          whoDoes[selected] == "Myself") ||
                                      hashtags.length < 2 ||
                                      (double.parse(moneyController.text) < 2 &&
                                          whoDoes[selected] == "Myself")) {
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
                                _carouselController.nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.linear);
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
                  return /*selected == -1
                      ? _choosePerson()
                      : */
                      CarouselSlider(
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
                        ? [
                            _choosePerson(),
                            _defineDescriptionSelf(),
                            _chooseCharity(),
                            _setHashtags(),
                            _imageUpload(),
                            _postPreview()
                          ]
                        : selected == 1
                            ? [
                                _choosePerson(),
                                _defineDescriptionOthers(),
                                _chooseCharity(),
                                _setHashtags(),
                                _imageUpload(),
                                _postPreview()
                              ]
                            : [_choosePerson()],
                  );
                },
              ),
            );
    }
  }

  void _changePage() {
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
    if (titleController.text == "" ||
        subtitleController.text == "" ||
        charity == -1 ||
        (moneyController.text == "0.00" && whoDoes[selected] == "Myself") ||
        hashtags.length < 2) {
      if (mounted) {
        setState(() {
          _current = 0;
          _submitting = false;
        });
      }
      _showErrorDialog('You have not filled all the required fields');
    } else {
      if (double.parse(moneyController.text) < 2 &&
          whoDoes[selected] == "Myself") {
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
                  title: titleController.text.toString().trimRight(),
                  subtitle: subtitleController.text.toString().trimRight(),
                  author: user.uid,
                  authorUsername: user.username,
                  charity: charities[charity].id,
                  noLikes: 0,
                  noComments: 0,
                  timestamp: DateTime.now(),
                  moneyRaised: 0,
                  targetAmount: moneyController.text.toString(),
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

                        // if the post is successfully added, view the post
                        /*DatabaseService(uid: user.uid).getPostById(postId.toString())
                      .then((post) => {
                        Navigator.of(context)
                          .pushReplacement(_viewPost(post))
                      })*/
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
                  title: titleController.text.toString(),
                  subtitle: subtitleController.text.toString(),
                  author: user.uid,
                  authorUsername: user.username,
                  charity: charities[charity].id,
                  likes: [],
                  comments: {},
                  timestamp: DateTime.now(),
                  moneyRaised: 0,
                  targetAmount: moneyController.text.toString(),
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

  Widget _choosePerson() {
    return Container(
        color: Colors.white,
        child: ListView(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.grey[200],
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: Colors.white,
                ),
                margin: EdgeInsets.only(top: 10),
              ),
            ),
            Container(
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                child: Text(
                  'Who do you want to do it',
                  style: TextStyle(
                    fontFamily: 'Founders Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
            GestureDetector(
              onTap: () {
                setState(() {
                  selected = 0;
                });
                _carouselController.nextPage();
              },
              child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                  margin: EdgeInsets.only(left: 20, right: 20),
                  height: 300,
                  decoration: BoxDecoration(
                      border: selected == 0
                          ? Border.all(color: HexColor('ff6b6c'), width: 3)
                          : Border.all(color: Colors.grey[200], width: 3),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: MyselfTile(selected == 0
                      ? HexColor('ff6b6c') //Color.fromRGBO(237, 106, 110, .3)
                      : Colors.grey[200])),
            ),
            SizedBox(height: 20),
            Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  'Or',
                  style: TextStyle(
                    fontFamily: 'Founders Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                )),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  selected = 1;
                });
                _carouselController.nextPage();
              },
              child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn,
                  margin: EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                      border: selected == 1
                          ? Border.all(color: HexColor('ff6b6c'), width: 3)
                          : Border.all(color: Colors.grey[200], width: 3),
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: OthersTile(selected == 1
                      ? HexColor('ff6b6c') //Color.fromRGBO(237, 106, 110, .3)
                      : Colors.grey[200])),
            ),
            SizedBox(height: 10),
          ],
        ));
  }

  // _defineDescription state:
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final hashtagController = TextEditingController();
  final descriptionController = TextEditingController();
  List<String> hashtags = [];

  Widget _defineDescriptionSelf() {
    return ListView(shrinkWrap: true, children: <Widget>[
      Container(
        color: Colors.grey[200],
        child: Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white,
          ),
          margin: EdgeInsets.only(top: 10),
        ),
      ),
      Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontFamily: 'Founders Grotesk',
                          ),
                          children: [
                        TextSpan(
                            text: 'Title of Challenge ',
                            style: TextStyle(
                              fontFamily: 'Founders Grotesk',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )),
                        TextSpan(
                            text: 'maximum 50 characters',
                            style: TextStyle(
                              fontFamily: 'Founders Grotesk',
                              fontSize: 12,
                            ))
                      ])),
                ),
                TextField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Eg. Hatford XV performs California Girls',
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'Founders Grotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                TextField(
                    controller: subtitleController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        hintText:
                            'Eg. We will sing @Cornmarket St 12pm Sunday')),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    'If',
                    style: TextStyle(
                      fontFamily: 'Founders Grotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                Row(children: [
                  Text(
                    '£',
                    style: TextStyle(
                        fontWeight: FontWeight.w100,
                        fontFamily: 'Founders Grotesk',
                        fontSize: 45,
                        color: HexColor('ff6b6c')),
                  ),
                  Expanded(
                    child: TextField(
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontWeight: FontWeight.w100,
                          fontFamily: 'Founders Grotesk',
                          fontSize: 45,
                          color: Colors.black,
                        ),
                        controller: moneyController,
                        decoration: InputDecoration(hintText: 'Amount in £')),
                  )
                ]),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    'is donated to',
                    style: TextStyle(
                      fontFamily: 'Founders Grotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                PrimaryFundderButton(
                  onPressed: () {
                    _carouselController.nextPage();
                  },
                  text: "Set Charity",
                )
              ])),
    ]);
  }

  Widget _defineDescriptionOthers() {
    return ListView(shrinkWrap: true, children: <Widget>[
      Container(
        color: Colors.grey[200],
        child: Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white,
          ),
          margin: EdgeInsets.only(top: 10),
        ),
      ),
      Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: RichText(
                      text: TextSpan(
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontFamily: 'Founders Grotesk',
                          ),
                          children: [
                        TextSpan(
                            text: "Title of Challenge ",
                            style: TextStyle(
                              fontFamily: 'Founders Grotesk',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )),
                        TextSpan(
                            text: 'maximum 50 characters',
                            style: TextStyle(
                              fontFamily: 'Founders Grotesk',
                              fontSize: 12,
                            ))
                      ])),
                ),
                TextField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Eg. Perform California Girls by Katy Perry',
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'Founders Grotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                TextField(
                    controller: subtitleController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        hintText: 'Eg. Sing on a crowded street')),
              ]))
    ]);
  }

  // _choosePerson state:

  // _setMoney state:
  final moneyController =
      MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');

  Widget _setHashtags() {
    return ListView(children: <Widget>[
      Container(
        color: Colors.grey[200],
        child: Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white,
          ),
          margin: EdgeInsets.only(top: 10),
        ),
      ),
      Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                              fontFamily: 'Founders Grotesk',
                            ),
                            children: [
                          TextSpan(
                              text:
                                  'Add some hashtags to help categorise your post ',
                              style: TextStyle(
                                fontFamily: 'Founders Grotesk',
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              )),
                          TextSpan(
                              text:
                                  "minimum 2, maximum 5. Press 'add' after every hashtag you would like to add.",
                              style: TextStyle(
                                fontFamily: 'Founders Grotesk',
                                fontSize: 12,
                              )),
                        ]))),
                Row(children: [
                  Expanded(
                      child: TextField(
                          inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z]"))
                      ],
                          controller: hashtagController,
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          decoration: InputDecoration(
                              hintText:
                                  'Only text allowed, press add for each hashtag'))),
                  hashtags.length < 5
                      ? FlatButton(
                          onPressed: () {
                            if (hashtags.contains(hashtagController.text) ==
                                    false &&
                                hashtagController.text != "") {
                              if (mounted) {
                                setState(() {
                                  hashtags.add(
                                      hashtagController.text.toLowerCase());
                                  hashtagController.text = "";
                                });
                              }
                            }
                          },
                          child: Text('Add'))
                      : Container()
                ]),
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: hashtags.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        dense: true,
                        title: Text("#" + hashtags[index]),
                        trailing: FlatButton(
                          child: Text('Delete',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              )),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                hashtags.removeAt(index);
                              });
                            }
                          },
                        ),
                      );
                    })
              ]))
    ]);
  }

  // _chooseCharity state:
  List<Charity> charities;
  int charity = -1;

  void _loadCharityList() async {
    charities = await DatabaseService(uid: "123").getCharityNameList();
    if (mounted) {
      setState(() {});
    }
  }

  Widget _chooseCharity() {
    return ListView(children: <Widget>[
      Container(
        color: Colors.grey[200],
        child: Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white,
          ),
          margin: EdgeInsets.only(top: 10),
        ),
      ),
      Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Which charity are you raising for?',
                style: TextStyle(
                  fontFamily: 'Founders Grotesk',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(
                        height: 10,
                      ),
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  shrinkWrap: true,
                  itemCount: charities != null ? charities.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      child: CharityTile(
                          charities[index], charity == index ? true : false),
                      onTap: () {
                        charity = index;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    );
                    /*ListTile(
                      dense: true,
                      leading: Builder(builder: (context) {
                        if (charity == index) {
                          return Icon(Icons.check_circle);
                        } else {
                          return Icon(Icons.check_circle_outline);
                        }
                      }),
                      title: Text('${charities[index].name}'),
                      trailing: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, '/charity/' + charities[index].id);
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: CachedNetworkImage(
                                imageUrl: charities[index].image)),
                      ),
                      onTap: () {
                        charity = index;
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    );*/
                  })
            ],
          )),
    ]);
  }

  // _imageUpload state
  PickedFile imageFile;
  final picker = ImagePicker();
  Widget _imageUpload() {
    return ListView(children: <Widget>[
      Container(
        color: Colors.grey[200],
        child: Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white,
          ),
          margin: EdgeInsets.only(top: 10),
        ),
      ),
      Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: RichText(
              text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                    fontFamily: 'Founders Grotesk',
                  ),
                  children: [
                TextSpan(
                    text: 'Add a photo to make your Fundder more recognisable ',
                    style: TextStyle(
                      fontFamily: 'Founders Grotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )),
                TextSpan(
                    text: selected == 0
                        ? 'optional'
                        : "required for 'do' feed challenges",
                    style: TextStyle(
                      fontFamily: 'Founders Grotesk',
                      fontSize: 12,
                    )),
              ]))),
      SizedBox(
        height: 30,
      ),
      Container(
          child: _decideImageView(),
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 40,
              minHeight: (MediaQuery.of(context).size.width - 40) * 9 / 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
          )),
      SizedBox(
        height: 40,
      ),
      PrimaryFundderButton(
        text: "Select an image",
        onPressed: () {
          _changePic();
        },
      ),
    ]);
  }

  void _changePic() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 350,
            child: Container(
              child: _buildBottomNavigationMenu(context),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  topRight: const Radius.circular(10),
                ),
              ),
            ),
          );
        });
  }

  // Helper functions for the image picker
  _openGallery() async {
    imageFile = await picker.getImage(source: ImageSource.gallery);
    if (mounted) {
      this.setState(() {});
    }
  }

  _openCamera() async {
    imageFile = await picker.getImage(source: ImageSource.camera);
    if (mounted) {
      this.setState(() {});
    }
  }

  _removePhoto() {
    imageFile = null;
    if (mounted) {
      this.setState(() {});
    }
  }

  Widget _decideImageView() {
    if (imageFile == null) {
      return Container();
    } else {
      File image =
          new File(imageFile.path); // Or any other way to get a File instance.
      _findAspectRatio(image);
      return Image.file(image);
    }
  }

  void _findAspectRatio(File image) async {
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    print(decodedImage.width);
    print(decodedImage.height);
    aspectRatio = decodedImage.width / decodedImage.height;
  }

  ListView _buildBottomNavigationMenu(context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(FontAwesome.trash_o),
          title: Text('Remove Current Photo'),
          onTap: () async {
            _removePhoto();
          },
        ),
        /*ListTile(
          leading: Icon(FontAwesome5Brands.facebook_square),
          title: Text('Import from Facebook'),
          onTap: () {},
        ),*/
        ListTile(
          leading: Icon(FontAwesome.camera),
          title: Text('Take Photo'),
          onTap: () {
            _openCamera();
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.image),
          title: Text('Choose From Library'),
          onTap: () {
            _openGallery();
          },
        ),
      ],
    );
  }

  Widget _postPreview() {
    return ListView(children: <Widget>[
      Container(
        color: Colors.grey[200],
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white,
          ),
          margin: EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                color: Colors.white,
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                child: Text(
                  selected == 0
                      ? 'This is what your post would look like:'
                      : 'This is what your challenge, one somebody accepts it, would look like:',
                  style: TextStyle(
                    fontFamily: 'Founders Grotesk',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              PostHeader(
                  postAuthorId: user.uid,
                  postAuthorUserName: user.username,
                  targetCharity: charities != null
                      ? charity != -1 ? charities[charity].id : ""
                      : "",
                  charityLogo: charities != null
                      ? charity != -1 ? charities[charity].image : ""
                      : ""),
              Container(
                child: SizedBox(child: _decideImageView()),
                margin: EdgeInsets.only(bottom: 10.0),
              ),
              PostBody(
                likesManager: null,
                maxLines: 99999999,
                postData: Post(
                    title: titleController.text,
                    subtitle: subtitleController.text,
                    hashtags: hashtags,
                    moneyRaised: 0,
                    targetAmount: selected != 1 ? moneyController.text : '-1'),
              )
            ],
          ),
        ),
      ),
    ]);
  }
}
