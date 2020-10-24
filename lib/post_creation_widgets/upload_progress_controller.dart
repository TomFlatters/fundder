import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_icons/flutter_icons.dart';
import '../services/database.dart';
import '../models/user.dart';
import 'package:provider/provider.dart';
import '../shared/loading.dart';
import '../global_widgets/buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/post.dart';
import '../post_widgets/postHeader.dart';
import '../post_widgets/postBody.dart';
import 'package:flutter/cupertino.dart';
import 'package:fundder/global_widgets/dialogs.dart';
import 'package:fundder/shared/constants.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import 'aspect_ratio_video.dart';

class UploadProgressScreen extends StatefulWidget {
  final String postId;
  UploadProgressScreen({this.postId});

  @override
  _UploadProgressState createState() => _UploadProgressState();
}

class _UploadProgressState extends State<UploadProgressScreen> {
  Post postData;
  bool _submitting = false;
  PickedFile _imageFile;
  dynamic _pickImageError;
  bool isVideo = false;
  VideoPlayerController _controller;
  VideoPlayerController _toBeDisposed;
  String _retrieveDataError;
  double aspectRatio;
  CarouselController _carouselController = CarouselController();
  int _current = 0;
  bool _loading = true;
  bool _compressing = false;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  final TextEditingController completionCommentController =
      TextEditingController();

  @override
  void initState() {
    reloadPost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text("Complete Fundder"),
          actions: _submitting == true
              ? null
              : <Widget>[
                  new FlatButton(
                      child: Text('Submit',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        if (mounted)
                          setState(() {
                            _submitting = true;
                          });
                        print('Submit pressed');
                        if (_imageFile != null) {
                          print('not null');
                          final String fileLocation = user.uid +
                              "/" +
                              DateTime.now().microsecondsSinceEpoch.toString();
                          if (isVideo == true) {
                            _controller?.pause();
                            if (mounted)
                              setState(() {
                                _compressing = true;
                              });
                            MediaInfo mediaInfo =
                                await VideoCompress.compressVideo(
                              _imageFile.path,
                              frameRate: 20,
                              quality: VideoQuality.DefaultQuality,
                              deleteOrigin: true, // It's false by default
                            );
                            if (mounted)
                              setState(() {
                                _compressing = false;
                              });
                            Uint8List image =
                                await _loadThumbnail(File(mediaInfo.path));
                            final documentDirectory =
                                await getApplicationDocumentsDirectory();

                            File file = File(path.join(
                                documentDirectory.path, 'imagetest.png'));

                            file.writeAsBytesSync(image);
                            print('got file');
                            String thumbnailUrl = await DatabaseService(
                                    uid: user.uid)
                                .uploadImage(
                                    file, fileLocation + '_video_thumbnail');
                            print('image uploaded');

                            DatabaseService(uid: user.uid)
                                .uploadVideo(File(mediaInfo.path), fileLocation)
                                .then((downloadUrl) => {
                                      print("Successful image upload"),
                                      print(downloadUrl),
                                      DatabaseService(uid: user.uid)
                                          .updatePostProgress(
                                              widget.postId,
                                              downloadUrl,
                                              Timestamp.now(),
                                              aspectRatio,
                                              thumbnailUrl)
                                          .then((value) => {
                                                Navigator.of(context).pop(null)
                                              }),
                                    });
                          } else {
                            DatabaseService(uid: user.uid)
                                .uploadImage(
                                    File(_imageFile.path), fileLocation)
                                .then((downloadUrl) => {
                                      print("Successful image upload"),
                                      print(downloadUrl),
                                      DatabaseService(uid: user.uid)
                                          .updatePostProgress(
                                              widget.postId,
                                              downloadUrl,
                                              Timestamp.now(),
                                              aspectRatio,
                                              null)
                                          .then((value) => {
                                                Navigator.of(context).pop(null)
                                              }),
                                    });
                          }
                        } else {
                          if (mounted)
                            setState(() {
                              _submitting = false;
                            });
                          print('Error');
                          DialogManager().createDialog(
                              'Error',
                              'You must upload video or image proof of completing the challenge for all the money to be donated. This will be checked by a moderator.',
                              context);
                        }
                      }),
                ],
          leading: Container(
              width: 100,
              child: IconButton(
                  icon: _current == 0
                      ? Icon(Icons.close)
                      : Icon(Icons.arrow_back),
                  onPressed: _current == 0
                      ? () {
                          Navigator.of(context).pop(null);
                        }
                      : () {
                          _carouselController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.linear);
                        }))),
      body: _submitting == true || _loading == true
          ? _submitting == true
              ? Container(
                  color: Colors.white,
                  child: Center(
                    child: Container(
                        height: MediaQuery.of(context).size.width,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Container(
                            // Use the properties stored in the State class.
                            /*width: animation.value,
                height: animation.value,
                child: Image.asset('assets/images/fundder_loading.png'),*/
                            child: Column(children: [
                              CupertinoActivityIndicator(),
                              SizedBox(
                                height: 50,
                              ),
                              Text(_compressing == true
                                  ? 'Compressing video. This may take up to a few minutes.'
                                  : 'Uploading media. This may take up to a few minutes.')
                            ]),
                          ),
                          // Define how long the animation should take.
                          // Provide an optional curve to make the animation feel smoother.
                        )), /*SpinKitChasingDots(
                color: Color(0xffA3D165),
                size: 50.0,
            ),*/
                  ),
                )
              : Loading()
          : _uploadImageVideo(),
    );
  }

  Future<Uint8List> _loadThumbnail(File file) async {
    final uint8list =
        await VideoThumbnail.thumbnailData(video: file.path, quality: 3);
    return uint8list;
  }

  void _changePage() {
    FocusScope.of(context).unfocus();
  }

  void reloadPost() async {
    print('reloading');
    postData = await DatabaseService(uid: "123").getPostById(widget.postId);
    setState(() {
      _loading = false;
    });
  }

  Widget _uploadImageVideo() {
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
                    text:
                        'Upload proof of completing the challenge. Once proof is uploaded and approved by a moderator, the raised money will be sent to charity',
                    style: TextStyle(
                      fontFamily: 'Founders Grotesk',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )),
                TextSpan(
                    text: 'optional',
                    style: TextStyle(
                      fontFamily: 'Founders Grotesk',
                      fontSize: 12,
                    )),
              ]))),
      SizedBox(
        height: 30,
      ),
      Container(
          child: Platform.isAndroid
              ? FutureBuilder<void>(
                  future: retrieveLostData(),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    return isVideo ? _previewVideo() : _previewImage();
                  },
                )
              : (isVideo ? _previewVideo() : _previewImage()),
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
        text: "Select Video",
        onPressed: () {
          _changeVideo();
        },
      ),
      SizedBox(
        height: 20,
      ),
      PrimaryFundderButton(
        text: "Select Image",
        onPressed: () {
          _changePic();
        },
      ),
    ]);
  }

  Future<void> _playVideo(PickedFile file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      _controller = VideoPlayerController.file(File(file.path));
      await _controller.setVolume(1.0);
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.play();
      if (mounted) setState(() {});
    }
  }

  void _onImageButtonPressed(ImageSource source, {BuildContext context}) async {
    if (_controller != null) {
      await _controller.setVolume(0.0);
    }
    if (isVideo) {
      _imageFile = await _picker.getVideo(source: source);
      _playVideo(_imageFile);
    } else {
      try {
        final pickedFile = await _picker.getImage(source: source);
        if (mounted)
          setState(() {
            _imageFile = pickedFile;
          });
      } catch (e) {
        if (mounted)
          setState(() {
            _pickImageError = e;
          });
      }
    }
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller.setVolume(0.0);
      _controller.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  // Called if video or image are available

  Widget _previewVideo() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return Center(child: Text('No media selected'));
    } else {
      aspectRatio =
          _controller.value.size.height / _controller.value.size.width;
      print(aspectRatio);
    }
    return AspectRatioVideo(_controller);
  }

  Widget _previewImage() {
    final Text retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFile != null) {
      File image = File(_imageFile.path);
      _findAspectRatio(image);
      return Image.file(image);
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return Center(child: Text('No media selected'));
    }
  }

  void _findAspectRatio(File image) async {
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    print(decodedImage.width);
    print(decodedImage.height);
    aspectRatio = decodedImage.width / decodedImage.height;
  }

  Future<void> retrieveLostData() async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
        await _playVideo(response.file);
      } else {
        isVideo = false;
        if (mounted)
          setState(() {
            _imageFile = response.file;
          });
      }
    } else {
      _retrieveDataError = response.exception.code;
    }
  }

  // called to bring up the menu to choose

  void _changeVideo() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 350,
            child: Container(
              child: _buildBottomNavigationMenuVideo(context),
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

  Text _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  ListView _buildBottomNavigationMenuVideo(context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(FontAwesome.trash_o),
          title: Text('Remove Current Video'),
          onTap: () async {
            _imageFile = null;
            if (mounted) this.setState(() {});
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.camera),
          title: Text('Take Video'),
          onTap: () {
            isVideo = true;
            _onImageButtonPressed(ImageSource.camera);
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.image),
          title: Text('Choose From Library'),
          onTap: () {
            isVideo = true;
            _onImageButtonPressed(ImageSource.gallery);
          },
        ),
      ],
    );
  }

  // same for image

  ListView _buildBottomNavigationMenu(context) {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(FontAwesome.trash_o),
          title: Text('Remove Current Photo'),
          onTap: () async {
            _imageFile = null;
            if (mounted) this.setState(() {});
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.camera),
          title: Text('Take Photo'),
          onTap: () {
            isVideo = false;
            _onImageButtonPressed(ImageSource.camera, context: context);
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.image),
          title: Text('Choose From Library'),
          onTap: () {
            isVideo = false;
            _onImageButtonPressed(ImageSource.gallery, context: context);
          },
        ),
      ],
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
}
