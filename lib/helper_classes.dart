import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

// This is called from the feed to retrieve the profile pic from uid rather than url

class ProfilePic extends StatefulWidget {
  @override
  _ProfilePicState createState() => _ProfilePicState();

  final String uid;
  final double size;
  ProfilePic(this.uid, this.size);
}

class _ProfilePicState extends State<ProfilePic> {
  String url =
      'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/images%2Fprofile_pic_default-01.png?alt=media&token=cea24849-7590-43f8-a2ff-b630801e7283';

  @override
  void initState() {
    if (widget.uid != null) {
      print("profile pic instantiated with uid " + widget.uid);
      _retrieveUser();
    } else {
      print("no uid provided");
    }
    super.initState();
  }

  @override
  void didUpdateWidget(ProfilePic oldwidget) {
    super.didUpdateWidget(oldwidget);
    if (widget.uid != null) {
      _retrieveUser();
    } else {
      print("no uid provided");
    }
  }

  void _retrieveUser() async {
    Firestore.instance
        .collection("users")
        .document(widget.uid)
        .get()
        .then((value) {
      if (mounted) {
        if (mounted)
          setState(() {
            if (value.data != null && value.data['profilePic'] != null) {
              url = value.data["profilePic"];
            }
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.size / 2,
      backgroundImage: CachedNetworkImageProvider(url),
      backgroundColor: Colors.transparent,
    );
  }
}

// This is called when url of the pic is known

class ProfilePicFromUrl extends StatelessWidget {
  final String url;
  final double size;
  ProfilePicFromUrl(this.url, this.size);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundImage: url == null
          ? CachedNetworkImageProvider(
              'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/images%2Fprofile_pic_default-01.png?alt=media&token=cea24849-7590-43f8-a2ff-b630801e7283')
          : CachedNetworkImageProvider(url),
      backgroundColor: Colors.transparent,
    );
  }
}
