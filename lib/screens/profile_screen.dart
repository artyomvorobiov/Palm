import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/profile_field.dart';
import '/providers/profiles.dart';
import '/screens/events_screen.dart';
import '/screens/personal_info_screen.dart';
import '/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/screens/favorite_events_screen.dart';

import '../providers/auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;
  File _photo;
  String _uploadedFileURL;
  String username = (Profiles.curProfile == null || Profiles.curProfile == '')
      ? 'Nickname'
      : Profiles.curProfile.username;

  void personalFunc(BuildContext context) async {
    String newUsername = await Navigator.of(context).pushNamed(
      PersonalInfoScreen.routeName,
    ) as String;
    if (newUsername != null && newUsername != '') {
      setState(() {
        username = newUsername;
      });
    }
  }

  Future imgFromGallery() async {
    final pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future imgFromCamera() async {
    final pickedFile = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child(Profiles.curProfileId + '.jpg')
          .putFile(_photo);

      _uploadedFileURL = await ref.then((res) => res.ref.getDownloadURL());
      setState(() {});
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

  void uploadPhoto() {
    FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child(Profiles.curProfileId + '.jpg')
        .getDownloadURL()
        .then((value) {
      setState(() {
        _uploadedFileURL = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    uploadPhoto();
    return Container(
      height: double.infinity,
      color: Theme.of(context).colorScheme.secondary,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _showPicker(context);
                    },
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: _uploadedFileURL != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(_uploadedFileURL,
                                  width:
                                      MediaQuery.of(context).size.height * 0.35,
                                  height:
                                      MediaQuery.of(context).size.height * 0.35,
                                  fit: BoxFit.fill),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(50)),
                              width: MediaQuery.of(context).size.height * 0.35,
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.grey[800],
                              ),
                            ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.height * 0.28,
                    height: MediaQuery.of(context).size.height * 0.10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(left: 25.0),
                    child: Text(
                      username,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ProfileField("Личные данные", () => personalFunc(context)),
            ProfileField("Настройки", () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
            }),
            ProfileField("Мои мероприятия", () {
              Navigator.of(context).pushNamed(
                EventsScreen.routeName,
              );
            }),
            ProfileField("Избранные мероприятия", () {
              Navigator.of(context).pushNamed(FavoriteEventsScreen.routeName);
            }),
            ProfileField("Выйти из аккаунта", () {
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            }),
          ],
        ),
      ),
    );
  }
}
