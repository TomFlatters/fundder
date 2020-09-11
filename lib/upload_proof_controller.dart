import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'services/database.dart';
import 'models/user.dart';
import 'package:provider/provider.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'shared/loading.dart';
import 'global_widgets/buttons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'models/post.dart';
import 'post_widgets/postHeader.dart';
import 'post_widgets/postBody.dart';
import 'package:flutter/cupertino.dart';
import 'package:visibility_detector/visibility_detector.dart';

class UploadProofScreen extends StatefulWidget {
  final String postId;
  UploadProofScreen({this.postId});

  @override
  _UploadProofState createState() => _UploadProofState();
}

class _UploadProofState extends State<UploadProofScreen> {
  Post postData;
  bool _submitting = false;
  PickedFile _imageFile;
  dynamic _pickImageError;
  bool isVideo = false;
  CachedVideoPlayerController _controller;
  CachedVideoPlayerController _toBeDisposed;
  String _retrieveDataError;
  double aspectRatio;
  CarouselController _carouselController = CarouselController();
  int _current = 0;
  bool _loading = true;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  final TextEditingController completionCommentController =
      TextEditingController();

  final Key _key = UniqueKey();

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
                      child: _current == 2
                          ? Text('Submit',
                              style: TextStyle(fontWeight: FontWeight.bold))
                          : _current == 0
                              ? Text('Next',
                                  style: TextStyle(fontWeight: FontWeight.bold))
                              : Text('Preview',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _current == 2
                          ? () {
                              if (mounted)
                                setState(() {
                                  _submitting = true;
                                });
                              print('Submit pressed');
                              if (_imageFile != null) {
                                print('not null');
                                final String fileLocation = user.uid +
                                    "/" +
                                    DateTime.now()
                                        .microsecondsSinceEpoch
                                        .toString();
                                if (isVideo == true) {
                                  DatabaseService(uid: user.uid)
                                      .uploadVideo(
                                          File(_imageFile.path), fileLocation)
                                      .then((downloadUrl) => {
                                            print("Successful image upload"),
                                            print(downloadUrl),
                                            DatabaseService(uid: user.uid)
                                                .updatePostStatusImageTimestampRatioComment(
                                                    widget.postId,
                                                    downloadUrl,
                                                    'done',
                                                    Timestamp.now(),
                                                    aspectRatio,
                                                    completionCommentController
                                                        .text)
                                                .then((value) => {
                                                      Navigator.of(context)
                                                          .pop(null)
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
                                                .updatePostStatusImageTimestampRatioComment(
                                                    widget.postId,
                                                    downloadUrl,
                                                    'done',
                                                    Timestamp.now(),
                                                    aspectRatio,
                                                    completionCommentController
                                                        .text)
                                                .then((value) => {
                                                      Navigator.of(context)
                                                          .pop(null)
                                                    }),
                                          });
                                }
                              } else {
                                if (mounted)
                                  setState(() {
                                    _submitting = false;
                                  });
                                print('Error');
                                _showErrorDialog(
                                    'You must upload video or image proof of completing the challenge for all the money to be donated. This will be checked by a moderator.');
                              }
                            }
                          : () {
                              if (_imageFile != null || _current == 0) {
                                _carouselController.nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.linear);
                              } else {
                                _showErrorDialog(
                                    'You must upload video or image proof of completing the challenge for all the money to be donated. This will be checked by a moderator.');
                              }
                            })
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
                              Text(
                                  'Uploading media. This may take up to a few minutes.')
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
          : Builder(
              builder: (context) {
                final double height = MediaQuery.of(context).size.height;
                return CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    onPageChanged: (index, reason) {
                      _changePage();
                      if (mounted) {
                        setState(() {
                          _current = index;
                        });
                      }
                    },
                    enableInfiniteScroll: false,
                    height: height,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    // autoPlay: false,
                  ),
                  items: _imageFile != null
                      ? [
                          _completionComment(),
                          _uploadImageVideo(),
                          _previewPost()
                        ]
                      : [_completionComment(), _uploadImageVideo()],
                );
              },
            ),
    );
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

  Widget _previewPost() {
    postData.imageUrl = null;
    if (completionCommentController.text != "") {
      postData.completionComment = completionCommentController.text;
    } else {
      postData.completionComment = null;
    }
    return ListView(children: [
      /*Container(
        decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.all(
              Radius.circular(10.0),
            )),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Text(
          'Upload proof of completing the challenge. Once proof is uploaded and approved by a moderator, the raised money will be sent to charity',
          style: TextStyle(
              fontFamily: 'Founders Grotesk',
              fontWeight: FontWeight.w500,
              fontSize: 18),
        ),
      ),*/
      Container(
        color: Colors.grey[200],
        child: Container(
          margin: EdgeInsets.only(top: 10),
          decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.all(
                Radius.circular(10.0),
              )),
          child: Column(children: <Widget>[
            PostHeader(
                postAuthorId: postData.author,
                postAuthorUserName: postData.authorUsername,
                targetCharity: postData.charity,
                charityLogo: postData.charityLogo),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.width * 9 / 16),
              color: Colors.grey[200],
              child: Center(child: isVideo ? _previewVideo() : _previewImage()),
            ),
            PostBody(
              postData: postData,
              hashtag: null,
              maxLines: 9999999999,
              likesManager: null,
            ),
            SizedBox(
              height: 60,
            )
          ]),
        ),
      )
    ]);
  }

  Widget _completionComment() {
    return ListView(children: [
      /*Container(
        decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.all(
              Radius.circular(10.0),
            )),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Text(
          'Upload proof of completing the challenge. Once proof is uploaded and approved by a moderator, the raised money will be sent to charity',
          style: TextStyle(
              fontFamily: 'Founders Grotesk',
              fontWeight: FontWeight.w500,
              fontSize: 18),
        ),
      ),*/
      Container(
          color: Colors.grey[200],
          child: Container(
              margin: EdgeInsets.only(top: 10),
              decoration: new BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.all(
                    Radius.circular(10.0),
                  )),
              child: Container(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                            text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black,
                                  fontFamily: 'Founders Grotesk',
                                ),
                                children: [
                              TextSpan(
                                  text: 'Add a completion comment ',
                                  style: TextStyle(
                                    fontFamily: 'Founders Grotesk',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  )),
                              TextSpan(
                                  text: 'this is optional',
                                  style: TextStyle(
                                    fontFamily: 'Founders Grotesk',
                                    fontSize: 12,
                                  ))
                            ])),
                        TextField(
                          controller: completionCommentController,
                          decoration: InputDecoration(
                            //border: InputBorder.none,
                            hintText: 'Name',
                          ),
                        ),
                      ]))))
    ]);
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
      PrimaryFundderButton(
        text: "Select Image",
        onPressed: () {
          _changePic();
        },
      ),
    ]);

    /*ListView(children: [
      /*Container(
        decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.all(
              Radius.circular(10.0),
            )),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Text(
          'Upload proof of completing the challenge. Once proof is uploaded and approved by a moderator, the raised money will be sent to charity',
          style: TextStyle(
              fontFamily: 'Founders Grotesk',
              fontWeight: FontWeight.w500,
              fontSize: 18),
        ),
      ),*/
      Container(
        color: Colors.grey[200],
        child: Container(
          margin: EdgeInsets.only(top: 10),
          decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.all(
                Radius.circular(10.0),
              )),
          child: Column(children: <Widget>[
            PostHeader(
                postAuthorId: postData.author,
                postAuthorUserName: postData.authorUsername,
                targetCharity: postData.charity,
                charityLogo: postData.charityLogo),
            Container(
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.width * 9 / 16),
              color: Colors.grey[200],
              child: Center(
                child: !kIsWeb && Platform.isAndroid
                    ? FutureBuilder<void>(
                        future: retrieveLostData(),
                        builder: (BuildContext context,
                            AsyncSnapshot<void> snapshot) {
                          return isVideo ? _previewVideo() : _previewImage();
                        },
                      )
                    : (isVideo ? _previewVideo() : _previewImage()),
              ),
            ),
          ]),
        ),
      ),
      SizedBox(height: 40),
      PrimaryFundderButton(
        text: "Select Video",
        onPressed: () {
          _changeVideo();
        },
      ),
      PrimaryFundderButton(
        text: "Select Image",
        onPressed: () {
          _changePic();
        },
      ),
      SizedBox(
        height: 40,
      )
    ]);*/
  }

  Future<void> _playVideo(PickedFile file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      if (kIsWeb) {
        _controller = CachedVideoPlayerController.network(file.path);
        // In web, most browsers won't honor a programmatic call to .play
        // if the video has a sound track (and is not muted).
        // Mute the video so it auto-plays in web!
        // This is not needed if the call to .play is the result of user
        // interaction (clicking on a "play" button, for example).
        await _controller.setVolume(0.0);
      } else {
        _controller = CachedVideoPlayerController.file(File(file.path));
        await _controller.setVolume(1.0);
      }
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
      aspectRatio = _controller.value.aspectRatio;
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
      if (kIsWeb) {
        // Why network?
        // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
        return Image.network(_imageFile.path);
      } else {
        File image = File(_imageFile.path);
        _findAspectRatio(image);
        return Image.file(image);
      }
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

  Future<void> _showErrorDialog(String string) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(string),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
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
}

class AspectRatioVideo extends StatefulWidget {
  AspectRatioVideo(this.controller);

  final CachedVideoPlayerController controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  CachedVideoPlayerController get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller.value.initialized) {
      initialized = controller.value.initialized;
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return VisibilityDetector(
          key: UniqueKey(),
          onVisibilityChanged: (VisibilityInfo info) {
            debugPrint("${info.visibleFraction} of my widget is visible");
            if (mounted) {
              if (info.visibleFraction < 0.3) {
                controller.pause();
              } else {
                controller.play();
              }
            }
          },
          child: Center(
              child: GestureDetector(
            onTap: _playPause,
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CachedVideoPlayer(controller),
            ),
          ) //)/*AspectRatio(
              /*aspectRatio: controller.value?.aspectRatio,
          child: VideoPlayer(controller),*/
              ));
      //);
    } else {
      return Container();
    }
  }

  _playPause() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }
}
