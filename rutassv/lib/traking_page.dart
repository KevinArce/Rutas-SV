import 'dart:async'; // for Future and FutureBuilder

import 'package:flutter/material.dart'; // for MaterialApp, etc.
import 'package:flutter_polyline_points/flutter_polyline_points.dart'; // for PolylinePoints
import 'package:google_maps_flutter/google_maps_flutter.dart'; // for GoogleMap
import 'package:location/location.dart'; // for Location
import 'package:rutassv/constants.dart'; // for googleApiKey

class TrackingPage extends StatefulWidget {
  // for StatefulWidget and State class below
  const TrackingPage({Key? key})
      : super(
            key:
                key); // for constructor and super call to StatefulWidget constructor

  @override
  State<TrackingPage> createState() => TrackingPageState();
}

class TrackingPageState extends State<TrackingPage> {
  // for State<TrackingPage> class below
  final Completer<GoogleMapController> _controller =
      Completer(); // for GoogleMapController object to be used in the map_created function

  static const LatLng sourceLocation = LatLng(
      13.7013, -89.2244); // latlng of source location (El Salvador del Mundo)

  static const LatLng destination = LatLng(
      13.7022, -89.2299); // latlng of destination location (C.C. Galerias)

  List<LatLng> polylineCoordinates = []; // List<LatLng>();
  LocationData?
      currentLocation; // for current location data to be used in the map_created function

  BitmapDescriptor sourceIcon =
      BitmapDescriptor.defaultMarker; // for source icon
  BitmapDescriptor destinationIcon =
      BitmapDescriptor.defaultMarker; // for destination icon
  BitmapDescriptor currentLocationIcon =
      BitmapDescriptor.defaultMarker; // for current location icon

  void getCurrentLocation() async {
    // async void
    Location location =
        Location(); // Location() is a class that is used to get the current location of the device

    location.getLocation().then((location) {
      // location.getLocation() is a method that returns a Future<LocationData> object
      currentLocation =
          location; // currentLocation is a variable that stores the current location of the device (latitude and longitude)
    });

    GoogleMapController googleMapController = await _controller
        .future; // for GoogleMapController object to be used in the map_created function

    location.onLocationChanged.listen((newLocation) {
      currentLocation = newLocation;

      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                newLocation
                    .latitude!, // for latitude to be used in the map_created function (newLocation.latitude!)
                newLocation
                    .longitude!, // for longitude to be used in the map_created function (newLocation.longitude!)
              ), // for LatLng object to be used in the map_created function
              zoom: 14.0), // for zoom to be used in the map_created function
        ),
      );

      setState(() {});
    });
  }

  void getPolyPoints() async {
    // async void function
    PolylinePoints polylinePoints =
        PolylinePoints(); // PolylinePoints() is a class that is used to get the polyline points between two locations

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      // Coordinates of the source and destination points of the route to be drawn.
      googleApiKey, // Google Maps API Key
      PointLatLng(sourceLocation.latitude,
          sourceLocation.longitude), // LatLng of source location
      PointLatLng(destination.latitude,
          destination.longitude), // LatLng of destination location
    ); // Calculate the points along the route

    if (result.points.isNotEmpty) {
      // If there is a route between source and destination
      for (var point in result.points) {
        // For each point in the route (latitude and longitude)
        polylineCoordinates.add(
          // Add to polylineCoordinates list the LatLng point
          LatLng(
              point.latitude,
              point
                  .longitude), // LatLng of each point in the route list of LatLng
        );
      } // End of forEach
      setState(() {
        // Set the state of the widget to trigger a rebuild
      });
    } // getPolyPoints
  }

  void setCustomMarkerIcon() {
    // void function
    BitmapDescriptor.fromAssetImage(
            // for size of the icon
            ImageConfiguration.empty,
            'assets/images/source_marker.png')
        .then((icon) {
      sourceIcon = icon;
    }); // for source icon
    // Get the bitmap descriptor from the asset image
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, 'assets/images/destination_marker.png')
        .then((icon) {
      destinationIcon = icon;
    }); // for destination icon
    // Get the bitmap descriptor from the asset image
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty,
            'assets/images/current_location_marker.png')
        .then((icon) {
      currentLocationIcon = icon;
    }); // for current location icon
  } // setCustomMarkerIcon

  @override // Override the build method to build the widget tree. This is where we build the UI.
  void initState() {
    // for initState function below
    getCurrentLocation(); // Get the current location of the device (latitude and longitude) before the build method is called
    //setCustomMarkerIcon(); // Set the custom marker icons
    getPolyPoints(); // Get the points along the route between source and destination
    super
        .initState(); // Call the superclass's initState method. This is where the build method is called.
  } // End of initState

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Rutas SV 🚌",
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: currentLocation ==
              null // If currentLocation is null (i.e. the device has not yet received the current location)
          ? const Center(
              // Center the widget
              child:
                  CircularProgressIndicator(), // Show a progress indicator while the device is getting the current location
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                // Initial camera position of the map (latitude and longitude)
                target: LatLng(
                    currentLocation!.latitude!,
                    currentLocation!
                        .longitude!), // Latitude of the current location
                zoom: 14.0, // Zoom level of the map
              ),
              polylines: {
                // List of polylines to be drawn on the map (i.e. the route between source and destination)
                Polyline(
                  // Polyline object
                  polylineId: const PolylineId(
                      "route"), // PolylineId is a string that is used to identify the polyline (i.e. route)
                  color: primaryColor, // Color of the polyline
                  points:
                      polylineCoordinates, // List of LatLng points along the route
                  width: 5, // Width of the polyline
                ),
              },
              markers: {
                // List of markers to be drawn on the map
                Marker(
                  // Marker object
                  markerId: const MarkerId("currentLocation"),
                  //icon: currentLocationIcon, // Icon of the marker
                  position: LatLng(
                      currentLocation!.latitude!,
                      currentLocation!
                          .longitude!), // LatLng of the current location of the device
                ),
                const Marker(
                  // Marker object
                  markerId: MarkerId(
                      "source"), // MarkerId is a string that is used to identify the marker (i.e. source)
                  //icon: sourceIcon, // Icon of the marker
                  position: sourceLocation, // LatLng of the source location
                ),
                const Marker(
                  // Marker object
                  markerId: MarkerId(
                      "destination"), // MarkerId is a string that is used to identify the marker (i.e. destination)
                  position: destination, // LatLng of the destination location
                  //icon: destinationIcon, // Icon of the marker
                ),
              },
              onMapCreated: (mapController) {
                // onMapCreated is a callback function that is called when the map is created
                _controller.complete(
                    mapController); // Complete the _controller Future with the mapController object
              }),
    );
  }
}
