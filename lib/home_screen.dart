import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:logging/logging.dart';


//define HomeScreen widget. stateful(can change over time). will be managed by the class _HomeScreenState.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key); // Add the key parameter

  @override
  HomeScreenState createState() => HomeScreenState();
}

//extends the HomeScreen widget to manage it
class HomeScreenState extends State<HomeScreen> {
  //holds current location data. make sure location package is included for LocationData to work
  LocationData? currentLocation;
  final Location locationService = Location();
  late GoogleMapController mapController;
  bool isMapInitialized = false;
  final Logger logger = Logger('HomeScreen');

  @override
  void initState() { //initialize location service when the state is created
    super.initState();
    initLocationService();
  }

  void initLocationService() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationService.serviceEnabled();
    if (!serviceEnabled) { // if location service is not enabled, if not request
      serviceEnabled = await locationService.requestService();
      if (!serviceEnabled) { //if connot be enabled, exit
        logger.warning("location disabled");
        return;
      }
    }

    permissionGranted = await locationService.hasPermission(); //check for location permission
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        logger.warning("Location permissions are denied.");
        return;
      }
    }

    LocationData locationData = await locationService.getLocation(); // Added line
      // Add this line
    setState(() {
      currentLocation = locationData;
    });


//when location changes, update currentLocation and call setState to refresh the UI
    locationService.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        currentLocation = locationData;
          mapController.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            ),
          );
      });
    });
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      isMapInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home screen'), //home screen will show bar titled Home
      ),
      body: currentLocation == null || !isMapInitialized
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 15.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}