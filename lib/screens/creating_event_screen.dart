import 'dart:io';
import 'package:intl/intl.dart';
import 'package:app/providers/address.dart';
import 'package:app/screens/search_places_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:provider/provider.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';

import '../widgets/popup_categories.dart';
import '../models/place.dart';
import '../providers/event.dart';
import '../providers/events.dart';
import '../widgets/image_input.dart';

class CreatingEventScreen extends StatefulWidget {
  static const routeName = '/creating-event';

  const CreatingEventScreen({Key key}) : super(key: key);

  @override
  State<CreatingEventScreen> createState() => _CreatingEventScreenState();
}

class _CreatingEventScreenState extends State<CreatingEventScreen> {
  SearchPlacesScreen searchPlacesScreen = SearchPlacesScreen();
  File _pickedImage;
  String title = 'Адрес';
  final _form = GlobalKey<FormState>();
  final _priceFocusNode = FocusNode();
  PlaceLocation _pickedLocation;

  Map<String, dynamic> redactedEvent = {
    'id': null,
    'dateTime': '',
    'description': '',
    'name': '',
    'price': '',
    'address': '',
    'extraInformation': '',
    'imageUrl': '',
    'categories': {
      'Спорт': false,
      'Развлечения': false,
      'Вечеринки': false,
      'Прогулка': false,
      'Искусство': false,
      'Обучение': false,
      'Концерт': false,
      'Настольные игры': false,
      'Гастрономия': false,
    },
    'creatorId': '',
  };
  bool showDateTime = false;

  Event event;
  bool alreadyBuild = false;
  Map<String, dynamic> oldCategories;
  Set<Marker> markersList = {};

  GoogleMapController googleMapController;

  final Mode _mode = Mode.overlay;
  int screen;

  // 1 - с центрального
  // 2 - при создании
  // 3 - при редактировании

  Future<DateTime> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      helpText: "",
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Theme.of(context).colorScheme.secondary,
              onSurface: Theme.of(context).primaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          child: child,
        );
      },
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
    return selectedDate;
  }

  Future<TimeOfDay> _selectTime(BuildContext context) async {
    TimeOfDay selectedTime = TimeOfDay.now();
    final selected = await showTimePicker(
      context: context,
      helpText: "",
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Theme.of(context).colorScheme.secondary,
              onSurface: Theme.of(context).primaryColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child,
        );
      },
    );
    if (selected != null && selected != selectedTime) {
      setState(() {
        selectedTime = selected;
      });
    }
    return selectedTime;
  }

  Future<String> _selectDateTime(BuildContext context) async {
    DateTime dateTime = null;
    final date = await _selectDate(context);
    if (date == null) return null;

    final time = await _selectTime(context);
    if (time == null) return null;

    setState(() {
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      redactedEvent['dateTime'] =
          dateTime.toString().substring(0, dateTime.toString().length - 4);
      copyData();
    });
  }

  String getTime(TimeOfDay tod) {
    final now = DateTime.now();

    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  void copyData() {
    event = Event(
      id: redactedEvent['id'],
      dateTime: redactedEvent['dateTime'],
      description: redactedEvent['description'],
      name: redactedEvent['name'],
      price: redactedEvent['price'],
      address: redactedEvent['address'],
      extraInformation: redactedEvent['extraInformation'],
      imagePath: redactedEvent['imagePath'],
      creatorId: redactedEvent['creatorId'],
      categories: redactedEvent['categories'],
    );
  }

  void _selectImage(File pickedImage) {
    _pickedImage = pickedImage;
  }

  // проба
  // void _selectPlace(double lat, double lng) {
  //   _pickedLocation = PlaceLocation(latitude: lat, longitude: lng);
  //   event.latitude = lat;
  //   event.longitude = lng;
  //   print('SELECTED PLACE ${event.latitude} ${event.longitude}');
  // }

  bool categoriesCorrect() {
    for (String categorie in event.categories.keys) {
      if (event.categories[categorie] == true) {
        return true;
      }
    }
    return false;
  }

  Future<bool> validate() async {
    // if (event.dateTime != '' && event.dateTime != null)
    if (event.description != '' && event.description != null) {
      if (event.name != '' && event.name != null) {
        if (event.price != '' && event.price != null) {
          if (event.address != '' && event.address != null) {
            if (event.extraInformation != '' &&
                event.extraInformation != null) {
              if (categoriesCorrect()) {
                return true;
              }
              print('Categories not input');
            }
            print('ExtraInfo not input');
          }
          print('Address not input');
        }
        print('Price not input');
      }
      print('Name not input');
    }
    print('Description not input');
    // if (event.imagePath !=
    //     '' &&
    // event.imagePath != null)
    await showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error occurred!'),
        content:
            Text('Вы не прошли валидацию. Какое-то из полей осталось пустым!'),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
    return false;
  }

  Future<void> _saveForm() async {
    _form.currentState.save();
    if (!await validate()) {
      return;
    }
    // event.latitude = _pickedLocation.latitude;
    // event.longitude = _pickedLocation.longitude;
    // print('COORDINATES ${event.latitude} ${event.longitude}');

    try {
      if (event.id != null) {
        await Provider.of<Events>(context, listen: false)
            .updateEvent(event.id, event);
      } else {
        await Provider.of<Events>(context, listen: false).addEvent(event);
      }
    } catch (error) {
      print("ERROR $error");
      await showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text('Something went wrong.'),
          actions: <Widget>[
            TextButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    Navigator.of(context).pop(event);
  }

  Future<Address> _handlePressButton() async {
    Prediction p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: _mode,
        language: 'ru',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
            hintText: 'Search',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.white))),
        components: [
          // Component(Component.country, "pk"),
          // Component(Component.country, "usa"),
          Component(Component.country, "ru"),
        ]);

    return displayPrediction(p, homeScaffoldKey.currentState);
  }

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Message',
        message: response.errorMessage,
        contentType: ContentType.failure,
      ),
    ));

    // homeScaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(response.errorMessage!)));
  }

  Future<Address> displayPrediction(
      Prediction p, ScaffoldState currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId);
    // String address = detail.result.formattedAddress;
    Address address =
        Address(id: p.placeId, title: detail.result.formattedAddress);
    return address;

    // markersList.clear();
    // markersList.add(Marker(
    //     markerId: const MarkerId("0"),
    //     position: LatLng(lat, lng),
    //     infoWindow: InfoWindow(title: detail.result.name)));

    // setState(() {});

    // googleMapController
    //     .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }

  String showCorCat(Map<String, dynamic> cat) {
    String res = '';
    for (String curCat in cat.keys) {
      if (cat[curCat] == true) {
        res += curCat + ', ';
      }
    }
    if (res.isEmpty) {
      res = 'Категории не выбраны';
    } else {
      res = res.substring(0, res.length - 2);
    }
    return res;
  }

  Widget makeField(
    String curInitialValue,
    String curLabelText,
    String fieldName,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // call this method here to hide soft keyboard
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(
            color: Theme.of(context).primaryColor,
          ),
        ),
        child: fieldName == 'categories'
            ? Container(
                width: double.infinity,
                child: TextButton(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      event.categories == '' || event.categories == null
                          ? 'Категории'
                          : showCorCat(event.categories),
                      style: TextStyle(
                          fontSize: 15, color: Theme.of(context).primaryColor),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    //  padding: EdgeInsets.only(right: 10),
                  ),
                  onPressed:
                      // FocusScope.of(context).requestFocus(new FocusNode()
                      // FocusScope.of(context).unfocus(),
                      func,
                ),
              )
            : (fieldName == 'address')
                ? Container(
                    width: double.infinity,
                    child: TextButton(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          curLabelText,
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        padding: EdgeInsets.only(right: 170),
                      ),
                      onPressed: setAddress,
                    ),
                  )
                : (fieldName == 'price')
                    ? TextFormField(
                        keyboardType: TextInputType.number,
                        initialValue: curInitialValue,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        decoration: InputDecoration(
                          labelText: curLabelText,
                          labelStyle:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        textInputAction: TextInputAction.next,
                        // focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: ((value) =>
                            value.isEmpty ? 'Please provide a name' : null),
                        onSaved: (value) {
                          redactedEvent[fieldName] = value;
                          copyData();
                        })
                    : (fieldName == 'dateTime')
                        ? Container(
                            width: double.infinity,
                            child: TextButton(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  event.dateTime == '' || event.dateTime == null
                                      ? 'Время не выбрано'
                                      : event.dateTime,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                padding: EdgeInsets.only(right: 170),
                              ),
                              onPressed: () => _selectDateTime(context),
                            ),
                          )
                        : TextFormField(
                            initialValue: curInitialValue,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                            decoration: InputDecoration(
                              labelText: curLabelText,
                              labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                            textInputAction: TextInputAction.next,
                            // focusNode: _priceFocusNode,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_priceFocusNode);
                            },
                            validator: ((value) =>
                                value.isEmpty ? 'Please provide a name' : null),
                            onSaved: (value) {
                              redactedEvent[fieldName] = value;
                              copyData();
                            },
                          ),
      ),
    );
  }

  void setAddress() async {
    Address address = await _handlePressButton();
    redactedEvent['address'] = Address(title: address.title, id: address.id);
    copyData();
    setState(() {
      title = address.title;
    });
  }

  void copyStartValues(Event event) {
    redactedEvent['id'] = event.id;
    redactedEvent['dateTime'] = event.dateTime;
    redactedEvent['description'] = event.description;
    redactedEvent['name'] = event.name;
    redactedEvent['price'] = event.price;
    redactedEvent['address'] = event.address;
    redactedEvent['extraInformation'] = event.extraInformation;
    redactedEvent['imagePath'] = event.imagePath;
    redactedEvent['creatorId'] = event.creatorId;
    redactedEvent['isFavorite'] = event.isFavorite;
    redactedEvent['categories'] = event.categories;
  }

  @override
  Widget build(BuildContext context) {
    if (!alreadyBuild) {
      event = ModalRoute.of(context).settings.arguments as Event;
      copyStartValues(event);
      alreadyBuild = true;
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Создание события', style: TextStyle(color: Colors.black)),
        /* actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save, color: Colors.black),
            onPressed: _saveForm,
          ),
        ], */
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          //color: Color.fromARGB(255, 2, 55, 69),
          child: Column(
            children: <Widget>[
              ImageInput(_selectImage, event, redactedEvent),
              SizedBox(height: 20),
              // LocationInput(_selectPlace),
              SizedBox(height: 20),
              Container(
                // color: Color.fromARGB(255, 2, 55, 69),
                child: Form(
                  key: _form,
                  child: Column(
                    children: <Widget>[
                      makeField(event.name, 'Название', 'name'),
                      makeField(event.price, 'Цена', 'price'),
                      makeField(
                          event.dateTime == null
                              ? ''
                              : event.dateTime.toString(),
                          'Время',
                          'dateTime'),
                      makeField(event.description, 'Описание', 'description'),
                      makeField(event.address.title, title, 'address'),
                      makeField(event.extraInformation,
                          'Дополнительная информация', 'extraInformation'),
                      makeField('', '', 'categories'),
                      Container(
                        child: TextButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(25)),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Theme.of(context).primaryColor,
                                        width: 1,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(20)))),
                          child: Text(
                            "Сохранить",
                            style: TextStyle(
                              fontSize: 19,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          onPressed: _saveForm,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> func() async {
    FocusScope.of(context).unfocus();
    dynamic newCategories = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => PopUpDialog(
          // screen: 2,
          oldCategories: event.categories,
        ).build(context),
      ),
    ) as Map<String, dynamic>;
    // print('CATEGORIESSSSS ${newCategories}');
    setState(() {
      redactedEvent['categories'] = newCategories;
      copyData();
    });
  }
}
