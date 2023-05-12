import 'package:app/providers/address.dart';
import 'package:app/providers/events.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

const kGoogleApiKey = 'AIzaSyBYg4SD_fvydAJIOBwZcKIVGqj_QxdFM1U';
final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(55.7522, 37.6156), zoom: 14.0);

  Set<Marker> markersList = {};

  GoogleMapController googleMapController;

  final Mode _mode = Mode.overlay;

  @override
  Widget build(BuildContext context) {
    if (markersList.length <= 1) {
      showExistMarkers();
    }
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialCameraPosition,
          markers: markersList,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            googleMapController = controller;
          },
        ),
        // ElevatedButton(
        //   onPressed: _handlePressButton,
        //   child: const Text("Search Places"),
        // ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                  // padding: const EdgeInsets.all(10),
                ),
                height: 50,
                child: IconButton(
                  icon: Icon(Icons.search),
                  color: Theme.of(context).primaryColor,
                  onPressed: _handlePressButton,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                  ),
                  color: Theme.of(context).colorScheme.secondary,
                  // padding: const EdgeInsets.all(10),
                ),
                height: 50,
                child: IconButton(
                  icon: Icon(Icons.location_on),
                  color: Theme.of(context).primaryColor,
                  onPressed: _getCurrentPosition,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _getCurrentPosition() async {
    final locData = await loc.Location().getLocation();
    final lat = locData.latitude;
    final lng = locData.longitude;
    final GoogleMapController controller = await googleMapController;
    markersList.add(Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: "Your location")));

    setState(() {});
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(lat, lng),
        zoom: 14.0,
      ),
    ));
  }

  Future<void> _handlePressButton() async {
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

    displayPrediction(p, homeScaffoldKey.currentState);
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

  void showExistMarkers() async {
    print("SHOW EXIST MARKERS");
    await Provider.of<Events>(context, listen: false).fetchAndSetEvents();
    var events = Provider.of<Events>(context, listen: false).events;
    PlacesDetailsResponse detail;
    Prediction prediction;
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());
    String address;
    events.forEach(
      (element) async {
        Address address = element.address;
        // address = element.address;
        prediction = Prediction(
          description: address.title,
          id: element.id,
          placeId: address.id,
          reference: element.id,
          types: [element.id],
        );
        // как получить placeId из адреса? - надо сделать запрос на сервер и получить placeId
        print("PREDECTION ${prediction.placeId} PLACE ID ${places == null}}");
        detail = await places.getDetailsByPlaceId(prediction.placeId);
        print(
            "COORDINATES ${detail.result.geometry.location.lat} ${detail.result.geometry.location.lng}");
        markersList.add(
          Marker(
            markerId: MarkerId(detail.result.name),
            position: LatLng(detail.result.geometry.location.lat,
                detail.result.geometry.location.lng),
            // infoWindow: InfoWindow(title: detail.result.name),
            infoWindow: InfoWindow(
              title: element.address.title,
              snippet: element.description,
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/event-detail',
                  arguments: element.id,
                );
              },
            ),
          ),
        );
        setState(() {});
      },
    );
  }

  Future<void> displayPrediction(
      Prediction p, ScaffoldState currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    print("PREDICTION ${p.placeId}");
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId);

    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;

    markersList.clear();
    markersList.add(Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name)));

    setState(() {});

    googleMapController
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }
}
