import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundder/main.dart';
import 'package:fundder/helper_classes.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fundder/services/database.dart';
import 'package:fundder/shared/loading.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fundder/global_widgets/dialogs.dart';
import 'package:fundder/services/auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fundder/shared/constants.dart';

class ProfilePicSetter extends StatefulWidget {
  @override
  _ProfilePicSetterState createState() => _ProfilePicSetterState();

  final String uid;
  ProfilePicSetter({this.uid});
}

class _ProfilePicSetterState extends State<ProfilePicSetter> {
  final AuthService _auth = AuthService();
  bool _facebookNotifCalled = false;
  bool _loading = false;
  bool _usernameSet = false;
  bool _nameSet = false;
  String _uid;
  String _profilePic;
  PickedFile imageFile;
  List fcmToken;
  final picker = ImagePicker();
  CarouselController _carouselController = CarouselController();
  int _current = 0;
  String _oldUsername;
  String _facebookId;
  String _facebookToken;

  var nameEntry = TextEditingController();
  var usernameEntry = TextEditingController();

  @override
  void initState() {
    _uid = widget.uid;
    _retrieveUser();
    super.initState();
  }

  void _retrieveUser() async {
    Firestore.instance
        .collection("users")
        .document(widget.uid)
        .get()
        .then((value) {
      if (mounted)
        setState(() {
          _uid = widget.uid;
          _profilePic = value.data["profilePic"];
          nameEntry.text = value.data['name'];
          usernameEntry.text = value.data['username'];
          _oldUsername = value.data['username'];
          _facebookId = value.data['facebookId'];
          _facebookToken = value.data['facebookToken'];
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: Text('Your profile'),
              actions: <Widget>[
                new FlatButton(
                  child: _current == 3
                      ? Text('Set',
                          style: TextStyle(fontWeight: FontWeight.bold))
                      : Text('Next',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: _current == 1
                      ? () async {
                          if ((usernameEntry.text == _oldUsername ||
                                  await _auth
                                          .usernameUnique(usernameEntry.text) ==
                                      true) &&
                              usernameEntry.text != '') {
                            print('username is unique or new');
                            setState(() {
                              _usernameSet = true;
                            });
                            _carouselController.nextPage();
                          } else {
                            if (mounted) {
                              setState(() {
                                _loading = false;
                              });
                            }
                            DialogManager().createDialog(
                                'Error', 'Username is taken', context);
                          }
                        }
                      : _current == 2
                          ? () {
                              if (nameEntry.text != '') {
                                print('name is set');
                                setState(() {
                                  _nameSet = true;
                                });
                                _carouselController.nextPage();
                              } else {
                                if (mounted) {
                                  setState(() {
                                    _loading = false;
                                  });
                                }
                                DialogManager().createDialog(
                                    'Error', 'Name cannot be empty', context);
                              }
                            }
                          : _current == 3
                              ? () async {
                                  if (mounted)
                                    setState(() {
                                      _loading = true;
                                    });
                                  if (usernameEntry.text == _oldUsername ||
                                      await _auth.usernameUnique(
                                              usernameEntry.text) ==
                                          true) {
                                    print('username is unique or new');
                                    if (nameEntry.text != '' &&
                                        usernameEntry.text != '') {
                                      if (_facebookToken != null) {
                                        final friendsGraphResponse = await http.get(
                                            'https://graph.facebook.com/v8.0/me/friends?access_token=$_facebookToken');

                                        final friends = json
                                            .decode(friendsGraphResponse.body);
                                        print('friends: ' + friends.toString());
                                        if (_facebookNotifCalled == false) {
                                          CloudFunctions()
                                              .getHttpsCallable(
                                                  functionName: 'facebookUser')
                                              .call([_uid, friends]);
                                          _facebookNotifCalled = true;
                                        }
                                      }
                                      if (imageFile != null) {
                                        final String fileLocation = _uid +
                                            "/" +
                                            DateTime.now()
                                                .microsecondsSinceEpoch
                                                .toString();
                                        DatabaseService(uid: _uid)
                                            .uploadImage(File(imageFile.path),
                                                fileLocation)
                                            .then((downloadUrl) => {
                                                  print(
                                                      "Successful image upload"),
                                                  print(downloadUrl),

                                                  // create post from the state and image url, and add that post to firebase
                                                  Firestore.instance
                                                      .collection('users')
                                                      .document(_uid)
                                                      .updateData({
                                                    'profilePic': downloadUrl,
                                                    'dpSetterPrompted': true,
                                                    'name': nameEntry.text,
                                                    'username':
                                                        usernameEntry.text,
                                                    'search_username':
                                                        usernameEntry.text
                                                            .toLowerCase(),
                                                  }).then((value) =>
                                                          Navigator.of(context)
                                                              .popUntil(
                                                                  ModalRoute
                                                                      .withName(
                                                                          '/')))
                                                });
                                      } else {
                                        print("updating uid = " + _uid);
                                        Firestore.instance
                                            .collection('users')
                                            .document(_uid)
                                            .updateData({
                                          'name': nameEntry.text,
                                          'username': usernameEntry.text,
                                          'search_username':
                                              usernameEntry.text.toLowerCase(),
                                        }).then((value) => Navigator.of(context)
                                                .popUntil(
                                                    ModalRoute.withName('/')));
                                      }
                                    } else {
                                      if (mounted) {
                                        setState(() {
                                          _loading = false;
                                        });
                                      }
                                      DialogManager().createDialog('Error',
                                          'You have not set a name', context);
                                    }
                                  } else {
                                    if (mounted) {
                                      setState(() {
                                        _loading = false;
                                      });
                                    }
                                    DialogManager().createDialog(
                                        'Error', 'Username is taken', context);
                                  }
                                }
                              : () {
                                  /*Navigator.of(context).pushReplacement(_viewPost());*/
                                  _carouselController.nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.linear);
                                },
                )
              ],
              leading: Container(
                  width: 100,
                  child: IconButton(
                      icon:
                          _current == 0 ? Container() : Icon(Icons.arrow_back),
                      onPressed: () {
                        _carouselController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.linear);
                      }))),
          body: _uid == null
              ? Loading()
              : Builder(
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
                        items: _usernameSet == false
                            ? [
                                _welcomeScreen(),
                                _usernamePrompter(),
                              ]
                            : _nameSet == false
                                ? [
                                    _welcomeScreen(),
                                    _usernamePrompter(),
                                    _namePrompter(),
                                  ]
                                : [
                                    _welcomeScreen(),
                                    _usernamePrompter(),
                                    _namePrompter(),
                                    _profilePicPrompter()
                                  ]);
                  },
                ),
        ));
  }

  void _changePage() {
    FocusScope.of(context).unfocus();
  }

  Widget _welcomeScreen() {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            height: 50,
            child: Image.asset('assets/images/pink_bear.png'),
          ),
          SizedBox(
            height: 20,
          ),
          Text('Welcome to Fundder',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 30)),
          SizedBox(
            height: 60,
          ),
        ]),
      ),
    );
  }

  Widget _usernamePrompter() {
    return Container(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontFamily: 'Founders Grotesk',
                      ),
                      children: [
                    TextSpan(
                        text: 'What would you like your username to be?',
                        style: TextStyle(
                          fontFamily: 'Founders Grotesk',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )),
                    TextSpan(
                        text: '',
                        style: TextStyle(
                          fontFamily: 'Founders Grotesk',
                          fontSize: 12,
                        ))
                  ])),
              TextField(
                onChanged: (string) {
                  setState(() {
                    _usernameSet = false;
                  });
                },
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp("[ ]"))
                ],
                controller: usernameEntry,
                decoration: textInputDecoration.copyWith(
                  //border: InputBorder.none,
                  hintText: 'Username',
                ),
              ),
            ]));
  }

  Widget _namePrompter() {
    return Container(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontFamily: 'Founders Grotesk',
                      ),
                      children: [
                    TextSpan(
                        text: 'What is your name? ',
                        style: TextStyle(
                          fontFamily: 'Founders Grotesk',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )),
                    TextSpan(
                        text: 'this will be visible on your profile',
                        style: TextStyle(
                          fontFamily: 'Founders Grotesk',
                          fontSize: 12,
                        ))
                  ])),
              TextField(
                onChanged: (string) {
                  setState(() {
                    _nameSet = false;
                  });
                },
                controller: nameEntry,
                decoration: textInputDecoration.copyWith(
                  //border: InputBorder.none,
                  hintText: 'Name',
                ),
              ),
            ]));
  }

  Widget _profilePicPrompter() {
    return Container(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: ListView(physics: NeverScrollableScrollPhysics(),
            //mainAxisAlignment: MainAxisAlignment.start,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontFamily: 'Founders Grotesk',
                      ),
                      children: [
                    TextSpan(
                        text: 'What would you like your profile photo to be? ',
                        style: TextStyle(
                          fontFamily: 'Founders Grotesk',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )),
                    TextSpan(
                        text: 'you can leave this empty for now',
                        style: TextStyle(
                          fontFamily: 'Founders Grotesk',
                          fontSize: 12,
                        ))
                  ])),
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 10),
                alignment: Alignment.center,
                child: Container(
                  child: imageFile != null
                      ? CircleAvatar(
                          radius: 45,
                          backgroundImage: FileImage(File(imageFile.path)),
                          backgroundColor: Colors.transparent)
                      : _profilePic != null
                          ? ProfilePicFromUrl(_profilePic, 90)
                          : ProfilePicFromUrl(null, 90),
                  margin: EdgeInsets.all(20.0),
                ),
              ),
              EditFundderButton(
                text: "Choose profile picture",
                onPressed: () {
                  _changePic();
                },
              ),
              SizedBox(
                height: 30,
              ),
            ]));
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
    if (mounted) this.setState(() {});
  }

  _openCamera() async {
    imageFile = await picker.getImage(source: ImageSource.camera);
    if (mounted) this.setState(() {});
  }

  _removePhoto() {
    imageFile = null;
    if (mounted) this.setState(() {});
  }

  Widget _decideImageView() {
    if (imageFile == null) {
      return Center(child: Text('No image selected'));
    } else {
      return Image.file(File(imageFile.path));
    }
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
}
