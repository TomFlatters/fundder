import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fundder/helper_classes.dart';
import 'package:fundder/post_creation_widgets/creation_tiles/tile_widgets/image_view.dart';
import 'package:fundder/post_creation_widgets/input_field_widgets/media_upload.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/**UI for uploading a photo. A Provider providing 'MediaStateManager'
 * must be above this widget in the widget tree.
 */

class ChallengePhotoUploadBox extends StatefulWidget {
  @override
  _ChallengePhotoUploadBoxState createState() =>
      _ChallengePhotoUploadBoxState();
}

class _ChallengePhotoUploadBoxState extends State<ChallengePhotoUploadBox> {
  final picker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.of(context).size.height) * 2 / 5;
    final width = MediaQuery.of(context).size.width;
    return Consumer<MediaStateManager>(
      builder: (_, state, __) {
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
                  _changePic(context);
                },
              )
            : FlatButton(
                child: ImageView(
                    imageFile: state.imageFile, height: height, width: width),
                onPressed: () {
                  _changePic(context);
                },
              );
      },
    );
  }

  void _changePic(main_context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 350,
            child: Container(
              child: _buildBottomNavigationMenu(
                main_context,
              ),
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

  ListView _buildBottomNavigationMenu(
    context,
  ) {
    final mediaState = Provider.of<MediaStateManager>(context, listen: false);
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(FontAwesome.trash_o),
          title: Text('Remove Current Media'),
          onTap: () async {
            mediaState.removeImageFile();
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.camera),
          title: Text('Take Photo'),
          onTap: () async {
            PickedFile _imageFile =
                await picker.getImage(source: ImageSource.camera);
            mediaState.updateImageFile(_imageFile);
          },
        ),
        ListTile(
          leading: Icon(FontAwesome.image),
          title: Text('Choose Image Library'),
          onTap: () async {
            PickedFile _imageFile =
                await picker.getImage(source: ImageSource.gallery);
            mediaState.updateImageFile(_imageFile);
          },
        ),
      ],
    );
  }
}
