import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/global_widgets/dialogs.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/post_creation_widgets/aspect_ratio_video.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/tile_widgets/image_view.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/input_field_validity_interface.dart';
import 'package:fundder/shared/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

/**State manager for MediaUploadBox. Keeps track of two files: video or photo. 
 * At any one time, at least one of the two should be null.
*/
class MediaStateManager with ChangeNotifier, InputFieldValidityChecker {
  PickedFile _imageFile = null;
  PickedFile _videoFile = null;

  /**Controller for the video player. Whenever the value of this changes (e.g.
   * if the user removes the video), the old VideoPlayerController must be
   * disposed using the dispose method. 
   */
  VideoPlayerController _videoController;

  VideoPlayerController get videoController {
    if (_videoController == null) {
      final vc = makeVideoController();
      return vc;
    } else {
      return this._videoController;
    }
  }

  /**Creates a new video player Controller for the current video file in
   * the state and sets it to the video controller of the state. Whenever the 
   * stateful widget using this state is disposed of, 'removeVideoPlayer' must
   * be called. 
   * PRECONDITON:
   * This should only be called when a video file exists in the state (i.e. this class)
   */

  VideoPlayerController makeVideoController() {
    if (_videoController != null) {
      removeVideoPlayer();
    }
    _videoController = VideoPlayerController.file(File(_videoFile.path));

    return _videoController;
  }

  PickedFile get videoFile => _videoFile;

/**Disposes of the current video controller held in the state and sets its value
 * to null.
 */
  void removeVideoPlayer() {
    print("Removing current video player.");
    if (this._videoController != null) {
      final oldVideoController = this._videoController;
      this._videoController = null;
      oldVideoController.dispose();
    }
  }

  PickedFile get imageFile {
    return _imageFile;
  }

  double _aspectRatio = 1;
  double get aspectRatio => _aspectRatio;
  void setAspectRatio(double ratio) {
    print("The new aspect ratio is $ratio");
    _aspectRatio = ratio;
  }

/**Updates the image file held in the state newImage */
  void updateImageFile(PickedFile newImage) {
    this._imageFile = newImage;
    notifyListeners();
  }

  void removeImageFile() {
    _imageFile = null;
    notifyListeners();
  }

/**Updates video  associated with that video */
  void updateVideoFile(PickedFile newVideo) {
    this._videoFile = newVideo;
    notifyListeners();
  }

/**Removes any video file stored in state. */
  void removeVideoFile() {
    _videoFile = null;
    if (_videoController != null) {
      removeVideoPlayer();
    }

    notifyListeners();
  }

  bool get hasImage {
    return _imageFile != null;
  }

  bool get hasVideo {
    print("The state has a video file?: ${_videoFile != null}");
    return _videoFile != null;
  }

  bool get isInputValid {
    return hasVideo || hasImage;
    print("Does the state have an image?: $hasImage");
    print("Does the state have a video?: $hasVideo");
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
  Function _disposeMethod = () {};

  @override
  void dispose() {
    _disposeMethod();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.of(context).size.height) * 2 / 5;
    final width = MediaQuery.of(context).size.width;

    return Consumer<MediaStateManager>(builder: (_, state, __) {
      //initialising now since this is the first point of access
      // to the state.
      this._disposeMethod = state.removeVideoPlayer;
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
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: HexColor('ff6b6c'),
                  )),
              onPressed: () {
                _changePic(
                    onAddingPic: state.updateImageFile,
                    onDeletingPic: state.removeImageFile,
                    onAddingVideo: state.updateVideoFile,
                    onDeletingVideo: state.removeVideoFile);
              },
            )
          : (state.hasVideo)
              ? FutureBuilder(
                  future: state.videoController.initialize(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      state.setAspectRatio(
                          state.videoController.value.aspectRatio);
                      state.videoController.play();
                      state.videoController.setVolume(0);
                      state.videoController.setLooping(true);
                      return AspectRatio(
                          child: VideoPlayer(state.videoController),
                          aspectRatio: state.videoController.value.aspectRatio);
                    } else {
                      return Container(
                          child: Loading(),
                          constraints: BoxConstraints(
                            minWidth: width,
                            minHeight: height,
                          ),
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
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.file_movie_o),
          title: Text('Choose Video From Library'),
          onTap: () async {
            PickedFile videoFile =
                await picker.getVideo(source: ImageSource.gallery);
            onAddingVideo(videoFile);
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
