import 'package:flutter/material.dart';
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

class ProfilePicSetter extends StatefulWidget {
  @override
  _ProfilePicSetterState createState() => _ProfilePicSetterState();

  final String uid;
  ProfilePicSetter({this.uid});
}

class _ProfilePicSetterState extends State<ProfilePicSetter> {
  bool _loading = false;
  String _uid;
  String _profilePic;
  PickedFile imageFile;
  List fcmToken;
  final picker = ImagePicker();

  @override
  void initState() {
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
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Set a profile picture'),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Set'),
              onPressed: () {
                if (mounted)
                  setState(() {
                    _loading = true;
                  });
                if (imageFile != null) {
                  final String fileLocation = _uid +
                      "/" +
                      DateTime.now().microsecondsSinceEpoch.toString();
                  DatabaseService(uid: _uid)
                      .uploadImage(File(imageFile.path), fileLocation)
                      .then((downloadUrl) => {
                            print("Successful image upload"),
                            print(downloadUrl),

                            // create post from the state and image url, and add that post to firebase
                            Firestore.instance
                                .collection('users')
                                .document(_uid)
                                .updateData({
                              'profilePic': downloadUrl,
                              'seenTutorial': false,
                              'dpSetterPrompted': true,
                            })
                          });
                } else {
                  Firestore.instance
                      .collection('users')
                      .document(_uid)
                      .updateData({
                    'dpSetterPrompted': true,
                  });
                }
                Navigator.of(context).pop(setState(() {}));
              })
        ],
        leading: new Container(),
      ),
      body: _uid == null || _loading == true
          ? Loading()
          : Column(children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 10),
                alignment: Alignment.center,
                child: Container(
                  child: imageFile != null
                      ? CircleAvatar(
                          radius: 70,
                          backgroundImage: FileImage(File(imageFile.path)),
                          backgroundColor: Colors.transparent)
                      : _profilePic != null
                          ? ProfilePicFromUrl(_profilePic, 140)
                          : ProfilePicFromUrl(null, 140),
                  margin: EdgeInsets.all(10.0),
                ),
              ),
              EditFundderButton(
                text: "Choose profile picture",
                onPressed: () {
                  _changePic();
                },
              ),
            ]),
    );
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
