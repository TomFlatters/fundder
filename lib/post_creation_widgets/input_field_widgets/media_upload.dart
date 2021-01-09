import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/global_widgets/dialogs.dart';

import 'package:fundder/helper_classes.dart';
import 'package:fundder/post_creation_widgets/aspect_ratio_video.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/tile_widgets/image_view.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_validity_interface.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

/**State manager for MediaUploadBox. Keeps track of two files: video or photo. 
 * At any one time, at least one of the two should be null.
*/
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

/**Removes any video file stored in state. */
  void removeVideoFile() {
    _videoFile = null;
    notifyListeners();
  }

  bool get hasImage {
    return _imageFile != null;
  }

  bool get hasVideo => _videoFile != null;

  bool get isInputValid {
    return hasVideo || hasImage;
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
  @override
  _MediaUploadBoxState createState() => _MediaUploadBoxState();
}

class _MediaUploadBoxState extends State<MediaUploadBox> {
  final picker = ImagePicker();

  /**Controller for the video player. Whenever the value of this changes (e.g.
   * if the user removes the video), the old VideoPlayerController must be
   * disposed using the dispose method. 
   */
  VideoPlayerController _videoController;
  /**a Future that attempts to open the data of video controller */
  Future<void> _initVideo;

  @override
  void dispose() {
    if (_videoController != null) {
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.of(context).size.height) * 2 / 5;
    final width = MediaQuery.of(context).size.width;
    print("The video player null status is ${_videoController == null}");
    return Consumer<MediaStateManager>(builder: (_, state, __) {
      return (!state.isInputValid)
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
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  )),
              onPressed: () {
                _changePic(
                    onAddingPic: state.updateImageFile,
                    onDeletingPic: state.removeImageFile,
                    onAddingVideo: state.updateVideoFile,
                    onDeletingVideo: state.removeVideoFile);
              },
            )
          : (state.hasVideo && _videoController != null)
              ? FutureBuilder(
                  future: _initVideo,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return AspectRatio(
                        child: VideoPlayer(_videoController),
                        aspectRatio: _videoController.value.aspectRatio,
                      );
                    } else {
                      return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ));
                    }
                  },
                )
              : FlatButton(
                  child: ImageView(
                      imageFile: state.imageFile, height: height, width: width),
                  onPressed: () {
                    _changePic(
                        onAddingPic: state.updateImageFile,
                        onDeletingPic: state.removeImageFile,
                        onAddingVideo: state.updateVideoFile,
                        onDeletingVideo: state.removeVideoFile);
                  },
                );
    });
  }

  void _changePic(
      {@required onAddingPic,
      @required onDeletingPic,
      @required onAddingVideo,
      @required onDeletingVideo}) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 350,
            child: Container(
              child: _buildBottomNavigationMenu(context,
                  onAddingPic: onAddingPic,
                  onDeletingPic: onDeletingPic,
                  onAddingVideo: onAddingVideo,
                  onDeletingVideo: onDeletingVideo),
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
      {@required onAddingPic,
      @required onDeletingPic,
      @required onAddingVideo,
      @required onDeletingVideo}) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(FontAwesome.trash_o),
          title: Text('Remove Current Media'),
          onTap: () async {
            //essentially reset the state to have no video or photo
            onDeletingVideo();
            //dispose of the _videoController
            if (this._videoController != null) {
              _videoController.dispose();
              _videoController = null;
            }
            _removePhoto(onDeletingPic: onDeletingPic);
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.video_camera),
          title: Text('Take Video'),
          onTap: () async {
            PickedFile videoFile =
                await picker.getVideo(source: ImageSource.camera);
            onAddingVideo(videoFile);
            setState(() {
              if (_videoController == null) {
                _videoController =
                    VideoPlayerController.file(File(videoFile.path));
              }
            });
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.file_movie_o),
          title: Text('Choose Video From Library'),
          onTap: () async {
            PickedFile videoFile =
                await picker.getVideo(source: ImageSource.gallery);
            onAddingVideo(videoFile);
            setState(() {
              if (_videoController == null) {
                _videoController =
                    VideoPlayerController.file(File(videoFile.path));
                _videoController.setVolume(1.0);
                _videoController.setLooping(true);
                _videoController.play();
                _initVideo = _videoController.initialize();
              }
            });
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
