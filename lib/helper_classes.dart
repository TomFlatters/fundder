import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

class ProfilePic extends StatelessWidget {
  final String url;
  final double size;

  ProfilePic(this.url, this.size);

   @override
  Widget build(BuildContext context) {
  return CircleAvatar(
    radius: size/2,
    backgroundImage:
      CachedNetworkImageProvider(url),
    backgroundColor: Colors.transparent,
  );

}

}
