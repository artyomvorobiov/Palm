import 'dart:io';

import 'package:app/providers/event.dart';
import 'package:app/providers/profiles.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import '../providers/profile.dart';

class ImageInput extends StatefulWidget {
  Event curEvent;
  final Function onSelectImage;
  Map<String, dynamic> redactedEvent;

  String futurePath;

  ImageInput(this.onSelectImage, this.curEvent, this.redactedEvent);

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File _storedImage;
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> _takePicture(bool fromGallery) async {
    File imageFile = null;
    if (fromGallery) {
      imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
      );
    } else {
      imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600,
      );
    }
    if (imageFile == null) {
      return;
    }

    widget.futurePath = imageFile.path;
    Profile curProfile = Profiles.curProfile;
    Profile.countOfEvents++;
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child(curProfile.id + Profile.countOfEvents.toString() + '.jpg')
        .putFile(imageFile);

    String url = await ref.then((res) => res.ref.getDownloadURL());
    widget.curEvent.imagePath = url;
    widget.redactedEvent['imagePath'] = url;
    print("FFFFFf ${widget.curEvent.imagePath}");

    setState(() {
      _storedImage = imageFile;
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final savedImage = await imageFile.copy('${appDir.path}/$fileName');
    widget.onSelectImage(savedImage);
  }

  Future imgFromGallery() async {
    final pickedFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    setState(() {
      if (pickedFile != null) {
        _storedImage = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    setState(() {
      if (pickedFile != null) {
        _storedImage = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_storedImage == null) return;
    Profile curProfile = Profiles.curProfile;
    Profile.countOfEvents++;
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child(curProfile.id + Profile.countOfEvents.toString() + '.jpg')
          .putFile(_storedImage);

      String url = await ref.then((res) => res.ref.getDownloadURL());
      widget.curEvent.imagePath = url;
      widget.redactedEvent['imagePath'] = url;

      setState(() {});

      final appDir = await syspaths.getApplicationDocumentsDirectory();
      final fileName = path.basename(_storedImage.path);
      final savedImage = await _storedImage.copy('${appDir.path}/$fileName');
      widget.onSelectImage(savedImage);
    } catch (e) {
      print('error occured');
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Gallery'),
                  onTap: () {
                    imgFromGallery();
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  imgFromCamera();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 150,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: _storedImage != null
              ? Image.file(
                  _storedImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : Text(
                  'No Image Taken',
                  textAlign: TextAlign.center,
                ),
          alignment: Alignment.center,
        ),
        SizedBox(height: 10),
        Expanded(
          child: TextButton.icon(
            icon: Icon(Icons.camera),
            label: Text('Take Picture'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
            ),
            // onPressed: () => _takePicture(false),
            onPressed: () => _showPicker(context),
          ),
        ),
      ],
    );
  }
}
