import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/global_widgets/dialogs.dart';

import 'package:fundder/helper_classes.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/tile_widgets/image_view.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_validity_interface.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/**State manager for MediaUploadBox*/
class MediaStateManager with ChangeNotifier, InputFieldValidityChecker {
  PickedFile _imageFile = null;
  PickedFile _videoFile = null;

  PickedFile get videoFile => _videoFile;

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

  void updateVideoFile(PickedFile newVideo) {
    this._videoFile = newVideo;
    notifyListeners();
  }

  void removeVideoFile() {
    _videoFile = null;
    notifyListeners();
  }

  bool get hasImage {
    return _imageFile != null;
  }

  bool get hasVideo => _videoFile != null;

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
          title: Text('Remove Current Media'),
          onTap: () async {
            //TODO: implement mechanism to remove video as well
            _removePhoto(onDeletingPic: onDeletingPic);
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.video_camera),
          title: Text('Take Video'),
          onTap: () {
            // _onImageButtonPressed(ImageSource.camera);
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.file_movie_o),
          title: Text('Choose Video From Library'),
          onTap: () {
            //_onImageButtonPressed(ImageSource.gallery);
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.camera),
          title: Text('Take Photo'),
          onTap: () {
            _openCamera(onAddingPic: onAddingPic);
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.image),
          title: Text('Choose Image Library'),
          onTap: () {
            _openGallery(onAddingPic: onAddingPic);
          },
        ),
      ],
    );
  }
}
