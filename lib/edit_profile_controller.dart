import 'package:flutter/material.dart';
import 'package:fundder/main.dart';
import 'helper_classes.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'services/database.dart';
import 'shared/loading.dart';
import 'global_widgets/buttons.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();

  final String uid;
  EditProfile({this.uid});
}

class _EditProfileState extends State<EditProfile> {
  String _username = "Username";
  String _name = "Name";
  String _uid;
  String _email = "Email";
  String _profilePic;
  PickedFile imageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    _retrieveUser();
    super.initState();
  }

  var nameEntry = TextEditingController();
  var usernameEntry = TextEditingController();
  var emailEntry = TextEditingController();

  final List<String> entries = <String>["Name", 'Username', 'Email'];
  final List<String> hints = <String>["Name", 'Username', 'Email'];

  void _retrieveUser() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection("users")
        .document(firebaseUser.uid)
        .get()
        .then((value) {
      setState(() {
        _uid = firebaseUser.uid;
        _name = value.data["name"];
        nameEntry.text = _name;
        _username = value.data['username'];
        _email = firebaseUser.email;
        emailEntry.text = _email;
        _profilePic = value.data["profilePic"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<TextEditingController> controllers = <TextEditingController>[
      nameEntry,
      usernameEntry,
      emailEntry
    ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Edit Profile'),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(setState(() {})),
          )
        ],
        leading: new Container(),
      ),
      body: _uid == null
          ? Loading()
          : ListView(shrinkWrap: true, children: <Widget>[
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
                  margin: EdgeInsets.all(10.0),
                ),
              ),
              EditFundderButton(
                text: "Change profile picture",
                onPressed: () {
                  _changePic();
                },
              ),
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 10.0),
                itemCount: entries.length,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          width: 80,
                          child: Text(entries[index])),
                      Expanded(
                        child: index == 1
                            ? Text(_uid == null ? "username" : _username)
                            : TextField(
                                controller: controllers[index],
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: hints[index],
                                ),
                              ),
                      )
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 10,
                  );
                },
              ),
              SecondaryFundderButton(
                text: 'Save Changes',
                onPressed: () {
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
                              DatabaseService(uid: _uid).updateUserData(
                                  emailEntry.text,
                                  _username,
                                  nameEntry.text,
                                  downloadUrl)
                            });
                  } else {
                    DatabaseService(uid: _uid).updateUserData(emailEntry.text,
                        _username, nameEntry.text, _profilePic);
                  }
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
    this.setState(() {});
  }

  _openCamera() async {
    imageFile = await picker.getImage(source: ImageSource.camera);
    this.setState(() {});
  }

  _removePhoto() {
    imageFile = null;
    this.setState(() {});
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
        ListTile(
          leading: Icon(FontAwesome5Brands.facebook_square),
          title: Text('Import from Facebook'),
          onTap: () {},
        ),
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

/*class ChangePic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
  }

  ListView _buildBottomNavigationMenu(context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(FontAwesome.trash_o),
          title: Text('Remove Current Photo'),
          onTap: () async {},
        ),
        ListTile(
          leading: Icon(FontAwesome5Brands.facebook_square),
          title: Text('Import from Facebook'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(FontAwesome.camera),
          title: Text('Take Photo'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(FontAwesome.image),
          title: Text('Choose From Library'),
          onTap: () {},
        ),
      ],
    );
  }

    // Helper functions for the image picker
  _openGallery() async {
    imageFile = await picker.getImage(source: ImageSource.gallery);
    this.setState(() {});
  }

  _openCamera() async {
    imageFile = await picker.getImage(source: ImageSource.camera);
    this.setState(() {});
  }

  _removePhoto() {
    imageFile = null;
    this.setState(() {});
  }

  Widget _decideImageView() {
    if (imageFile == null) {
      return Center(child: Text('No image selected'));
    } else {
      return Image.file(File(imageFile.path));
    }
  }
}*/
