import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fundder/global_widgets/buttons.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'tile_widgets/image_view.dart';

class ImageUpload extends StatefulWidget {
  final Function(double) aspectRatioChange;
  final Function(PickedFile) imageFileChange;
  final PickedFile imageFile;
  final int selected;
  final double aspectRatio;
  ImageUpload(
      {this.selected,
      this.aspectRatio,
      this.aspectRatioChange,
      this.imageFileChange,
      this.imageFile});
  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  PickedFile imageFile;
  final picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
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
                    text: widget.selected == 0
                        ? 'optional'
                        : "required for challenges",
                    style: TextStyle(
                      fontFamily: 'Founders Grotesk',
                      fontSize: 12,
                    )),
              ]))),
      SizedBox(
        height: 30,
      ),
      Container(
          child: ImageView(
            aspectRatioChange: widget.aspectRatioChange,
            imageFile: widget.imageFile,
          ),
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
      SizedBox(
        height: 20,
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
    widget.imageFileChange(imageFile);
    if (mounted) {
      this.setState(() {});
    }
  }

  _openCamera() async {
    imageFile = await picker.getImage(source: ImageSource.camera);
    widget.imageFileChange(imageFile);
    if (mounted) {
      this.setState(() {});
    }
  }

  _removePhoto() {
    imageFile = null;
    widget.imageFileChange(imageFile);
    if (mounted) {
      this.setState(() {});
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
