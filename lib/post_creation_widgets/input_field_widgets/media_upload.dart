import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:fundder/helper_classes.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/tile_widgets/image_view.dart';
import 'package:image_picker/image_picker.dart';

/**Widget handling valid video/image upload */

class MediaUploadBox extends StatefulWidget {
  @override
  _MediaUploadBoxState createState() => _MediaUploadBoxState();
}

class _MediaUploadBoxState extends State<MediaUploadBox> {
  PickedFile _imageFile;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.of(context).size.height) * 2 / 5;
    final width = MediaQuery.of(context).size.width;

    return (_imageFile == null)
        ? FlatButton(
            child: Container(
                alignment: Alignment.center,
                child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                          fontFamily: 'Founders Grotesk',
                        ),
                        children: [
                      TextSpan(
                          text:
                              'Add a photo to make your Fundder more recognisable ',
                          style: TextStyle(
                            fontFamily: 'Founders Grotesk',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )),
                    ])),
                constraints: BoxConstraints(
                  minWidth: width,
                  minHeight: height,
                ),
                decoration: BoxDecoration(
                  color: HexColor('ff6b6c'),
                )),
            onPressed: () {
              _changePic();
            },
          )
        : FlatButton(
            child:
                ImageView(imageFile: _imageFile, height: height, width: width),
            onPressed: () {
              _changePic();
            },
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
    _imageFile = await picker.getImage(source: ImageSource.gallery);

    this.setState(() {});
  }

  _openCamera() async {
    _imageFile = await picker.getImage(source: ImageSource.camera);

    this.setState(() {});
  }

  _removePhoto() {
    _imageFile = null;
    ;

    this.setState(() {});
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
