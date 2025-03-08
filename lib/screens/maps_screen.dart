import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class DisasterMapScreen extends StatefulWidget {
  const DisasterMapScreen({super.key});

  @override
  _DisasterMapScreenState createState() => _DisasterMapScreenState();
}

class _DisasterMapScreenState extends State<DisasterMapScreen> {
  GoogleMapController? _mapController;
  LocationData? _currentLocation;
  Location _locationService = Location();
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _locationError = false;

  final String firebaseUrl = 'https://relieflink-e824d-default-rtdb.firebaseio.com';

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  /// Initialize map by getting location and disasters
  Future<void> _initializeMap() async {
    bool locationSuccess = await _getUserLocation();

    if (locationSuccess) {
      await _fetchDisasterLocations();
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Get user's current location
  Future<bool> _getUserLocation() async {
    try {
      bool serviceEnabled = await _locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        if (!serviceEnabled) {
          print("❌ Location services are disabled.");
          setState(() => _locationError = true);
          return false;
        }
      }

      PermissionStatus permissionGranted = await _locationService.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _locationService.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          print("❌ Location permission denied.");
          setState(() => _locationError = true);
          return false;
        }
      }

      LocationData? location = await _locationService.getLocation();
      setState(() {
        _currentLocation = location;
      });

      // Move camera to user location if map is ready
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(location.latitude!, location.longitude!),
          ),
        );
      }
      return true;
    } catch (e) {
      print("❌ Error getting location: $e");
    }

    setState(() => _locationError = true);
    return false;
  }

  /// Fetch disaster locations from Firebase RTDB
  Future<void> _fetchDisasterLocations() async {
    final String apiUrl = "$firebaseUrl/disasters.json";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = jsonDecode(response.body);

        if (data != null) {
          Set<Marker> newMarkers = {};

          data.forEach((key, value) {
            _addMarker(key, value, newMarkers);
          });

          setState(() {
            _markers = newMarkers;
          });
        }
      } else {
        print("❌ Failed to fetch disasters: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error fetching disasters: $e");
    }
  }

  /// Helper function to add markers with random disaster types
  void _addMarker(String key, dynamic value, Set<Marker> markerSet) {
    double lat = (value['latitude'] ?? 0.0).toDouble();
    double lng = (value['longitude'] ?? 0.0).toDouble();
    
    // List of disaster types
    List<String> disasterTypes = ["Earthquake", "Flood", "Tsunami"];
    
    // Randomly select a disaster type
    String randomType = disasterTypes[Random().nextInt(disasterTypes.length)];

    String description = value['description'] ?? "No description available";
    String criticalLevel = value['criticalLevel'] ?? "Moderate";

    markerSet.add(
      Marker(
        markerId: MarkerId(key),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(
          title: randomType, // Assign the random type
          snippet: "$description\nSeverity: $criticalLevel",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          criticalLevel == "Critical"
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueRed,
        ),
      ),
    );
  } 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _locationError
              ? Center(child: Text("⚠️ Unable to get location. Please enable GPS and grant permissions."))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentLocation?.latitude ?? 0.0,
                      _currentLocation?.longitude ?? 0.0,
                    ),
                    zoom: 0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _getUserLocation();
                  },
                ),
    );
  }
}















// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class DisasterMapScreen extends StatefulWidget {
//   const DisasterMapScreen({super.key});

//   @override
//   _DisasterMapScreenState createState() => _DisasterMapScreenState();
// }

// class _DisasterMapScreenState extends State<DisasterMapScreen> {
//   GoogleMapController? _mapController;
//   LocationData? _currentLocation;
//   Location _locationService = Location();
//   Set<Marker> _markers = {};
//   bool _isLoading = true;
//   bool _locationError = false;

//   final String firebaseUrl = 'https://relieflink-e824d-default-rtdb.firebaseio.com';

//   @override
//   void initState() {
//     super.initState();
//     _initializeMap();
//   }

//   /// Initialize map by getting location and disasters
//   Future<void> _initializeMap() async {
//     bool locationSuccess = await _getUserLocation();

//     if (locationSuccess) {
//       await _fetchDisasterLocations();
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   /// Get user's current location
//   Future<bool> _getUserLocation() async {
//     try {
//       bool serviceEnabled = await _locationService.serviceEnabled();
//       if (!serviceEnabled) {
//         serviceEnabled = await _locationService.requestService();
//         if (!serviceEnabled) {
//           print("❌ Location services are disabled.");
//           setState(() => _locationError = true);
//           return false;
//         }
//       }

//       PermissionStatus permissionGranted = await _locationService.hasPermission();
//       if (permissionGranted == PermissionStatus.denied) {
//         permissionGranted = await _locationService.requestPermission();
//         if (permissionGranted != PermissionStatus.granted) {
//           print("❌ Location permission denied.");
//           setState(() => _locationError = true);
//           return false;
//         }
//       }

//       LocationData? location = await _locationService.getLocation();
//       setState(() {
//         _currentLocation = location;
//       });

//       // Move camera to user location if map is ready
//       if (_mapController != null) {
//         _mapController!.animateCamera(
//           CameraUpdate.newLatLng(
//             LatLng(location.latitude!, location.longitude!),
//           ),
//         );
//       }
//       return true;
//         } catch (e) {
//       print("❌ Error getting location: $e");
//     }

//     setState(() => _locationError = true);
//     return false;
//   }

//   /// Fetch disaster locations from Firebase RTDB
//   Future<void> _fetchDisasterLocations() async {
//     final String apiUrl = "$firebaseUrl/disasters.json";

//     try {
//       final response = await http.get(Uri.parse(apiUrl));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic>? data = jsonDecode(response.body);

//         if (data != null) {
//           Set<Marker> newMarkers = {};

//           data.forEach((key, value) {
//             _addMarker(key, value, newMarkers);
//           });

//           setState(() {
//             _markers = newMarkers;
//           });
//         }
//       } else {
//         print("❌ Failed to fetch disasters: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("❌ Error fetching disasters: $e");
//     }
//   }

//   /// Helper function to add markers safely
//   void _addMarker(String key, dynamic value, Set<Marker> markerSet) {
//     double lat = (value['latitude'] ?? 0.0).toDouble();
//     double lng = (value['longitude'] ?? 0.0).toDouble();
//     String type = value['type'] ?? "Unknown";
//     String description = value['description'] ?? "No description available";
//     String criticalLevel = value['criticalLevel'] ?? "Moderate";

//     markerSet.add(
//       Marker(
//         markerId: MarkerId(key),
//         position: LatLng(lat, lng),
//         infoWindow: InfoWindow(
//           title: type,
//           snippet: "$description\nSeverity: $criticalLevel",
//         ),
//         icon: BitmapDescriptor.defaultMarkerWithHue(
//           criticalLevel == "Critical"
//               ? BitmapDescriptor.hueRed
//               : BitmapDescriptor.hueRed,
//         ),
//       ),
//     );
//   } 
 
//   @override 
//   Widget build(BuildContext context) { 
//     return Scaffold(
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _locationError
//               ? Center(child: Text("⚠️ Unable to get location. Please enable GPS and grant permissions."))
//               : GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: LatLng(
//                       _currentLocation?.latitude ?? 0.0,
//                       _currentLocation?.longitude ?? 0.0,
//                     ),
//                     zoom: 0,
//                   ),
//                   markers: _markers,
//                   myLocationEnabled: true,
//                   onMapCreated: (GoogleMapController controller) {
//                     _mapController = controller;
//                     _getUserLocation();
//                   },
//                 ),
//     );
//   }
// }
