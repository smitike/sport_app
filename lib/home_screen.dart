import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';


//define HomeScreen widget. stateful(can change over time). will be managed by the class _HomeScreenState.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key); // Add the key parameter

  @override
  HomeScreenState createState() => HomeScreenState();
}


class HomeScreenState extends State<HomeScreen> { //extends the HomeScreen widget to manage it
  LocationData? currentLocation; //holds current location data. make sure location package is included for LocationData to work
  final Location locationService = Location();

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
        return;
      }
    }

    permissionGranted = await locationService.hasPermission(); //check for location permission
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationService.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

//when location changes, update currentLocation and call setState to refresh the UI
    locationService.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        this.currentLocation = currentLocation;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home screenn'), //home screen will show bar titled Home
      ),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                center: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                      builder: (ctx) => Container(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
    

