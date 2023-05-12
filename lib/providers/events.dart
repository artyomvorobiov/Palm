import 'dart:convert';

import '../models/http_exception.dart';
import '/providers/event.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/providers/address.dart';

class Events with ChangeNotifier {
  List<Event> _events = [];
  final String authToken;
  final String userId;

  Events(this.authToken, this.userId, this._events);

  List<Event> get events {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._events];
  }

  List<Event> get favoriteEvents {
    return _events.where((event) => event.isFavorite).toList();
  }

  Event findById(String id) {
    return _events.firstWhere((event) => event.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   // notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   // notifyListeners();
  // }

  bool setFavoriteStatus(Map<String, dynamic> favEvents, String prodId) {
    print('prodId ${prodId}');
    //print('res ${favEvents[prodId]}');
    if (favEvents == null) {
      return false;
    }
    if (favEvents[prodId] == null) {
      print('Come null');
      return false;
    }
    return favEvents[prodId];
  }

  Future<void> fetchAndSetEvents([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    // print("FILTER $filterString");
    var url =
        'https://flutter-shop-6df73-default-rtdb.firebaseio.com/events.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(Uri.parse(url));
      var extractedData;

      print("RESPONSE ${response.body}");
      if (response.body.isEmpty) {
        print("object");
        extractedData = null;
        return;
      }

      var obj = json.decode(response.body);
      if (obj == '') {
        obj = null;
        return;
      }
      extractedData = obj as Map<String, dynamic>;

      url =
          'https://flutter-shop-6df73-default-rtdb.firebaseio.com/userFavoritesEvents/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(Uri.parse(url));
      final favEvents = json.decode(favoriteResponse.body);
      print('favoriteEvents ${favEvents}');

      final List<Event> loadedProducts = [];

      // print("DATA $extractedData");

      extractedData.forEach(
        (prodId, prodData) {
          print("DATA $prodId $prodData");
          loadedProducts.add(
            Event(
              id: prodId,
              dateTime: prodData['dateTime'],
              description: prodData['description'],
              name: prodData['name'],
              price: prodData['price'],
              imagePath: prodData['imageUrl'],
              address: Address(
                id: prodData['address']['id'],
                title: prodData['address']['title'],
              ),
              extraInformation: prodData['extraInformation'],
              isFavorite: setFavoriteStatus(favEvents, prodId),
              categories: prodData['categories'],
              creatorId: prodData['creatorId'],
            ),
          );
        },
      );
      _events = loadedProducts;
      notifyListeners();
    } catch (error) {
      print("ERROR EVENTS");
      throw (error);
    }
  }

  Future<void> addEvent(Event event) async {
    print("HFKJFHJKF ${event.imagePath}");
    final url =
        'https://flutter-shop-6df73-default-rtdb.firebaseio.com/events.json?auth=$authToken';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'name': event.name,
          'description': event.description,
          'price': event.price,
          'imageUrl': event.imagePath,
          'address': {
            'title': event.address.title,
            'id': event.address.id,
          },
          'extraInformation': event.extraInformation,
          'dateTime': event.dateTime,
          'creatorId': userId,
          'categories': event.categories,
        }),
      );

      final newEvent = Event(
        name: event.name,
        description: event.description,
        price: event.price,
        imagePath: event.imagePath,
        address: event.address,
        extraInformation: event.extraInformation,
        dateTime: event.dateTime,
        categories: event.categories,
        creatorId: event.creatorId,
        id: json.decode(response.body)['name'],
      );
      _events.add(newEvent);
      notifyListeners();
    } catch (error) {
      print("ERROR $error");
      throw error;
    }
  }

  Future<void> updateEvent(String id, Event newEvent) async {
    final prodIndex = _events.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-shop-6df73-default-rtdb.firebaseio.com/events/$id.json?auth=$authToken';
      await http.patch(
        Uri.parse(url),
        body: json.encode(
          {
            'name': newEvent.name,
            'description': newEvent.description,
            'imageUrl': newEvent.imagePath,
            'address': {
              'title': newEvent.address.title,
              'id': newEvent.address.id,
            },
            'extraInformation': newEvent.extraInformation,
            'dateTime': newEvent.dateTime,
            'price': newEvent.price,
            'categories': newEvent.categories,
          },
        ),
      );
      _events[prodIndex] = newEvent;
      notifyListeners();
    } else {
      // print('...');
    }
  }

  Future<void> deleteEvent(String id) async {
    final url =
        'https://flutter-shop-6df73-default-rtdb.firebaseio.com/events/$id.json?auth=$authToken';
    // final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    // var existingProduct = _items[existingProductIndex];
    // _items.removeAt(existingProductIndex);
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode >= 400) {
      // _items.insert(existingProductIndex, existingProduct);
      // notifyListeners();
      throw HttpException('Could not delete product.');
    }
    notifyListeners();
    // existingProduct = null;
  }
}
