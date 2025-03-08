import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:relieflink/screens/gemini_api.dart';

class GeminiMapScreen extends StatefulWidget {
  const GeminiMapScreen({super.key});

  @override
  _GeminiMapScreenState createState() => _GeminiMapScreenState();
}

class _GeminiMapScreenState extends State<GeminiMapScreen> {
  late GoogleMapController mapController;
  List<LatLng> coordinates = [];
  List<String> locationNames = [];
  List<String> crisisTitles = [];
  Set<Marker> markers = {};

  Future<void> fetchCoordinates() async {
    const String prompt = """
    Provide a JSON object containing a list of disaster-prone areas with their latitude and longitude, along with the type of crisis (e.g., Flood, Tsunami, Earthquake, etc.).
    Only return a valid JSON object with no additional text.
    Example format:

    {
      "locations": [
        {"name": "Tokyo, Japan", "latitude": 35.6895, "longitude": 139.6917, "crisis": "Earthquake"},
        {"name": "Delhi, India", "latitude": 28.7041, "longitude": 77.1025, "crisis": "Flood"},
        {"name": "California, USA", "latitude": 36.7783, "longitude": -119.4179, "crisis": "Wildfire"}
      ]
    }
    """;

    try {
      final String response = await GeminiService.generateText(prompt);
      final String cleanedResponse = response.replaceAll(RegExp(r'```json|```'), '').trim();
      final Map<String, dynamic> jsonData = jsonDecode(cleanedResponse);

      if (jsonData.containsKey("locations")) {
        setState(() {
          coordinates = (jsonData["locations"] as List)
              .map((location) => LatLng(
                    location["latitude"],
                    location["longitude"],
                  ))
              .toList();

          locationNames = (jsonData["locations"] as List)
              .map((location) => location["name"] as String)
              .toList();

          crisisTitles = (jsonData["locations"] as List)
              .map((location) => location["crisis"] as String)
              .toList();

          markers = coordinates.asMap().entries.map((entry) {
            int index = entry.key;
            LatLng coord = entry.value;
            return Marker(
              markerId: MarkerId(locationNames[index]),
              position: coord,
              infoWindow: InfoWindow(title: "Likely ${crisisTitles[index]}"),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            );
          }).toSet();
        });
      }
    } catch (e) {
      debugPrint("❌ Error parsing JSON: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCoordinates();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(20.5937, 78.9629), // Default: India
          zoom: 3.0,
        ),
        markers: markers,
      ),
    );
  }
}