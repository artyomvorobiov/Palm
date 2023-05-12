import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/providers/profile.dart';

class Profiles with ChangeNotifier {
  List<Profile> _profiles;
  final String authToken;
  final String userId;

  static String curEmail;
  static String curProfileId;
  static Profile curProfile;

  Profiles(this.authToken, this.userId, this._profiles);

  List<Profile> get profiles {
    return [..._profiles];
  }

  Future<bool> alreadyAdded() async {
    await fetchAndSetProfile();
    // print('PROFILES ${_profiles.length}');
    for (Profile profile in _profiles) {
      // print('${profile.email}');
      if (profile.email == curEmail) {
        curProfile = profile;
        curProfileId = profile.id;
        return true;
      }
    }
    return false;
  }

  void setEmail() async {
    var url =
        'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=AIzaSyA4s3N3M8oSVu14OeizNiIiaioiqEDaH6w';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'idToken': authToken,
          },
        ),
      );
      final responseData = json.decode(response.body);
      curEmail = responseData['users'][0]['email'];
      //print("RESPONSE$responseData");
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetProfile([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://flutter-shop-6df73-default-rtdb.firebaseio.com/profiles.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final profiles = json.decode(response.body);

      final List<Profile> loadedProfiles = [];
      extractedData.forEach((prodId, prodData) {
        loadedProfiles.add(
          Profile(
            id: prodId,
            firstName: prodData['firstName'],
            lastName: prodData['lastName'],
            username: prodData['username'],
            description: prodData['description'],
            email: prodData['email'],
            age: prodData['age'],
            male: prodData['male'],
          ),
        );
      });
      _profiles = loadedProfiles;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProfile(String email) async {
    final url =
        'https://flutter-shop-6df73-default-rtdb.firebaseio.com/profiles.json?auth=$authToken';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'firstName': '',
          'lastName': '',
          'username': '',
          'description': '',
          'email': email,
          'age': '',
          'male': '',
        }),
      );

      final newProfile = Profile(
        firstName: '',
        lastName: '',
        username: '',
        description: '',
        email: email,
        age: '',
        male: '',
        id: json.decode(response.body)['name'],
      );
      curProfileId = json.decode(response.body)['name'];
      _profiles.add(newProfile);
      curProfile = newProfile;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // void setCurrentProfile() async {
  //   print('SET PROFILE $curProfileId');
  //   Uri url = Uri.parse(
  //       'https://flutter-shop-6df73-default-rtdb.firebaseio.com/profiles/$curProfileId.json?auth=$authToken');
  //   final response = await http.get(url);

  //   final responseData = json.decode(response.body);
  //   Profile loadedProfile = Profile(
  //     id: responseData['id'],
  //     firstName: responseData['firstName'],
  //     lastName: responseData['lastName'],
  //     username: responseData['username'],
  //     description: responseData['description'],
  //     email: responseData['email'],
  //     age: responseData['age'],
  //     male: responseData['male'],
  //   );
  //   print('CUR PROFILE ${loadedProfile}');
  //   curProfile = loadedProfile;
  // }

  Future<void> updateProfile(String id, Profile newProfile) async {
    //final prodIndex = _profiles.indexWhere((prod) => prod.email == curEmail);
    //if (prodIndex >= 0) {
    final url =
        'https://flutter-shop-6df73-default-rtdb.firebaseio.com/profiles/$id.json?auth=$authToken';
    await http.patch(
      Uri.parse(url),
      body: json.encode(
        {
          'firstName': newProfile.firstName,
          'lastName': newProfile.lastName,
          'username': newProfile.username,
          'description': newProfile.description,
          'email': newProfile.email,
          'age': newProfile.age,
          'male': newProfile.male,
          // 'myEvents': newProfile.myEvents,
          // 'favoriteEvents': newProfile.favoriteEvents,
        },
      ),
    );
    curProfile = newProfile;
    //_profiles[prodIndex] = newProfile;
    notifyListeners();
    // } else {
    //   print('Er 120562');
    // }
  }
}
