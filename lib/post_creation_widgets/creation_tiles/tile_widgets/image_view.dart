import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageView extends StatelessWidget {
  final PickedFile imageFile;
  final double height;
  final double width;

  ImageView({this.imageFile, @required this.height, @required this.width});

  @override
  Widget build(BuildContext context) {
    if (imageFile == null) {
      return Container(child: Text("Add an image or a video"));
    } else {
      File image =
          new File(imageFile.path); // Or any other way to get a File instance.
      _findAspectRatio(image);
      return Image.file(
        image,
        width: this.width,
        height: this.height,
      );
    }
  }

  void _findAspectRatio(File image) async {
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    print(decodedImage.width);
    print(decodedImage.height);
    double aspectRatio = decodedImage.width / decodedImage.height;
  }
}
