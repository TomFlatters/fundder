import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageView extends StatelessWidget {
  final PickedFile imageFile;
  final Function(double) aspectRatioChange;
  ImageView({this.aspectRatioChange, this.imageFile});

  @override
  Widget build(BuildContext context) {
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
    double aspectRatio = decodedImage.width / decodedImage.height;
    aspectRatioChange(aspectRatio);
  }
}
