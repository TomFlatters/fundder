import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/global_widgets/dialogs.dart';

import 'package:fundder/helper_classes.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/tile_widgets/image_view.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_validity_interface.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/**Widget handling valid video/image upload */

// class MediaInputField extends InputField {
//   bool _isValid = false;
//   bool get isInputValid {
//     return _isValid;
//   }

//   void _updateValidity(bool newValidity) {
//     _isValid = newValidity;
//     print("validity status of media input field is ${newValidity.toString()}");
//   }

//   StatefulWidget buildWidget() =>
//       MediaUploadBox(updateValidityFunction: this._updateValidity);
// }

/**State manager for MediaUploadBox*/
class MediaStateManager with ChangeNotifier, InputFieldValidityChecker {
  PickedFile _imageFile = null;

  PickedFile get imageFile {
    return _imageFile;
  }

  double _aspectRatio;
  double get aspectRatio => _aspectRatio;
  void setAspectRatio(double ratio) => _aspectRatio = ratio;

  void updateImageFile(PickedFile newImage) {
    this._imageFile = newImage;
    notifyListeners();
  }

  void removeImageFile() {
    _imageFile = null;
    notifyListeners();
  }

  bool get hasImage {
    return _imageFile != null;
  }

  bool get isInputValid {
    //TODO: amend implementation after adding support for videoing.
    return hasImage;
  }

  void createErrorDialog(context) {
    DialogManager().createDialog(
      'Error',
      'Please upload a video or image for your Fundder on the first screen',
      context,
    );
  }
}

/**UI for uploading a video or a photo. A Provider providing 'MediaStateManager'
 * must be above this widget in the widget tree.
 */
class MediaUploadBox extends StatefulWidget {
  /*Dependency injection constructor called after media is uploaded or removed. */

  @override
  _MediaUploadBoxState createState() => _MediaUploadBoxState();
}

class _MediaUploadBoxState extends State<MediaUploadBox> {
  // PickedFile _imageFile;

  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.of(context).size.height) * 2 / 5;
    final width = MediaQuery.of(context).size.width;

    return Consumer<MediaStateManager>(builder: (_, state, __) {
      return (!state.hasImage)
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
                                'Tap to add a video or photo for your Fundder ',
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
                _changePic(
                    onAddingPic: state.updateImageFile,
                    onDeletingPic: state.removeImageFile);
              },
            )
          : FlatButton(
              child: ImageView(
                  imageFile: state.imageFile, height: height, width: width),
              onPressed: () {
                _changePic(
                    onAddingPic: state.updateImageFile,
                    onDeletingPic: state.removeImageFile);
              },
            );
    });
  }

  void _changePic({@required onAddingPic, @required onDeletingPic}) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 350,
            child: Container(
              child: _buildBottomNavigationMenu(context,
                  onAddingPic: onAddingPic, onDeletingPic: onDeletingPic),
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
  _openGallery({@required onAddingPic}) async {
    PickedFile _imageFile = await picker.getImage(source: ImageSource.gallery);

    onAddingPic(_imageFile);
  }

  _openCamera({@required onAddingPic}) async {
    PickedFile _imageFile = await picker.getImage(source: ImageSource.camera);

    onAddingPic(_imageFile);
  }

  _removePhoto({@required onDeletingPic}) {
    onDeletingPic();
  }

  ListView _buildBottomNavigationMenu(context,
      {@required onAddingPic, @required onDeletingPic}) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(FontAwesome.trash_o),
          title: Text('Remove Current Photo'),
          onTap: () async {
            _removePhoto(onDeletingPic: onDeletingPic);
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
            _openCamera(onAddingPic: onAddingPic);
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.image),
          title: Text('Choose From Library'),
          onTap: () {
            _openGallery(onAddingPic: onAddingPic);
          },
        ),
      ],
    );
  }
}
