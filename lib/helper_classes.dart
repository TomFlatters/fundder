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
class ProfilePic extends StatelessWidget {
  static Map<String, String> existingPics = {};
  final String uid;
  final double size;
  ProfilePic(this.uid, this.size);

  Future<String> _getPicUrlFromId(id) async {
    var userDoc =
        await Firestore.instance.collection("users").document(id).get();
    return userDoc["profilePic"];
  }

  @override
  Widget build(BuildContext context) {
    return (existingPics.containsKey(uid))
        ? CircleAvatar(
            radius: size / 2,
            backgroundImage: CachedNetworkImageProvider(existingPics[uid]),
            backgroundColor: Colors.transparent,
          )
        : FutureBuilder(
            future: _getPicUrlFromId(uid),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var url = snapshot.data;
                var profilePic = CircleAvatar(
                  radius: size / 2,
                  backgroundImage: CachedNetworkImageProvider(url),
                  backgroundColor: Colors.transparent,
                );
                existingPics[uid] = url;
                print("User images that are cached: {$existingPics}");
                return profilePic;
              } else {
                return CircleAvatar(
                  radius: size / 2,
                  backgroundImage: CachedNetworkImageProvider(
                      'https://firebasestorage.googleapis.com/v0/b/fundder-c4a64.appspot.com/o/images%2Fprofile_pic_default-01.png?alt=media&token=cea24849-7590-43f8-a2ff-b630801e7283'),
                  backgroundColor: Colors.transparent,
                );
              }
            },
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
