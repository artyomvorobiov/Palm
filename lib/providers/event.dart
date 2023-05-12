import 'dart:convert';

import 'package:app/providers/address.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;

Map<String, bool> buttonNameContains = {
  'Спорт': false,
  'Развлечения': false,
  'Вечеринки': false,
  'Прогулка': false,
  'Искусство': false,
  'Обучение': false,
  'Концерт': false,
  'Настольные игры': false,
  'Гастрономия': false,
};

class Event with ChangeNotifier {
  final String id;
  final String dateTime;
  final String description;
  final String name;
  final String price;
  final Address address;
  final String extraInformation;
  String imagePath;
  final String creatorId;
  bool isFavorite;
  Map<String, dynamic> categories;

  Event({
    @required this.id,
    @required this.dateTime,
    @required this.description,
    @required this.name,
    @required this.price,
    @required this.address,
    @required this.extraInformation,
    this.imagePath,
    @required this.creatorId,
    this.isFavorite = false,
    this.categories,
  });

  void _setFavoriteValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  // void getOldFavStatus(String token, String userId, String eventId) async {
  //   bool newIsFavorite;
  //   final url =
  //       'https://flutter-shop-6df73-default-rtdb.firebaseio.com/userFavoritesEvents/$userId/$eventId.json?auth=$token';
  //   try {
  //     final response = await http.get(
  //       Uri.parse(url),
  //     );
  //     print('OLD PESPONSE ${response}');
  //     print('OLD BODY ${response.body}');
  //     if (response.body == true) {
  //       print("FJMKL");
  //       isFavorite = true;
  //     } else {
  //       isFavorite = false;
  //     }
  //     print('OLD IsFAvorite ${isFavorite}');
  //     notifyListeners();
  //   } catch (error) {
  //     throw (error);
  //   }
  // }

  void toggleFavoriteStatus(
      String token, String userId, String eventId, bool newIsFav) async {
    // final oldStatus = isFavorite;
    // isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://flutter-shop-6df73-default-rtdb.firebaseio.com/userFavoritesEvents/$userId/$eventId.json?auth=$token';
    try {
      final response = await http.put(
        Uri.parse(url),
        body: json.encode(
          newIsFav,
        ),
      );
      if (response.statusCode >= 400) {
        _setFavoriteValue(!newIsFav);
        // _setFavoriteValue(oldStatus);
      }
    } catch (error) {
      _setFavoriteValue(!newIsFav);
    }
  }

  void output(Event event) {
    // print('EEEEEEEVVVVEEEEENNNNNTTT');
    // print("NAME ${event.name}");
    // print(event.description);
    // print(event.price);
    // print(event.address);
    // print(event.extraInformation);
    // print(event.dateTime);
    // print("CREATOR ${event.creatorId}");
    // print(event.categories);
  }
}
