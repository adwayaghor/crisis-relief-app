import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:relieflink/models/crisis_update_card.dart';
import 'package:relieflink/screens/ai_map_screen.dart';
import 'package:relieflink/screens/forum_screen.dart';
import 'package:relieflink/screens/maps_screen.dart';

abstract class Crisis {
  final String title;
  final String description;
  final String country;
  final String date;
  final String criticalLevel;

  Crisis({
    required this.title,
    required this.description,
    required this.country,
    required this.date,
    required this.criticalLevel,
  });
}

class NaturalDisaster extends Crisis {
  final String disasterType;

  NaturalDisaster({
    required super.title,
    required super.description,
    required this.disasterType,
    required super.country,
    required super.date,
    required super.criticalLevel,
  });

  factory NaturalDisaster.fromJson(Map<String, dynamic> json) {
    return NaturalDisaster(
      title: json['name'] ?? 'No Title',
      description: json['description'] ?? 'No Description Available',
      disasterType: json['type']?[0]['name'] ?? 'Unknown',
      country: json['country']?[0]['name'] ?? 'Unknown Location',
      date: json['date']?['created'] ?? 'Date Unknown',
      criticalLevel: 'High',
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Dio _dio = Dio();
  List<Crisis> crises = [];
  bool isLoading = true;
  bool isError = false;
  String selectedCategory = "natural_disaster";
  int _currentPage = 0; // Track current page index

  @override
  void initState() {
    super.initState();
    fetchCrisisData();
  }

  Future<void> fetchCrisisData() async {
    String url;
    if (selectedCategory == "natural_disaster") {
      url = 'https://api.reliefweb.int/v1/disasters?appname=relieflink&limit=5';
    } else if (selectedCategory == "humanitarian_conflict") {
      url = 'https://api.reliefweb.int/v1/reports?appname=relieflink&limit=5';
    } else {
      url =
          'https://api.reliefweb.int/v1/reports?appname=relieflink&limit=5&query[disease]=true';
    }

    try {
      final response = await _dio.get(url);
      final List<dynamic> data = response.data['data'];

      setState(() {
        crises = data.map((e) {
          if (selectedCategory == "natural_disaster") {
            return NaturalDisaster.fromJson(e['fields']);
          } else {
            return NaturalDisaster.fromJson(e['fields']);
          }
        }).toList();
        isLoading = false;
        isError = false;
      });
    } catch (e) {
      print('Error fetching crisis data: $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crisis Dashboard')),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _currentPage == 0 ? 'Urgent Crises' : 'Predicted Crises',
                    style: const TextStyle(
                        fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentPage = 0;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentPage == 0
                                  ? Colors.blueAccent
                                  : Colors.grey,
                            ),
                            child: const Text('Urgent Crises'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _currentPage = 1;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentPage == 1
                                  ? Colors.blueAccent
                                  : Colors.grey,
                            ),
                            child: const Text('Predicted Crises'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: MediaQuery.of(context).size.width - 32,
                        height: 200.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: _currentPage == 0
                              ? DisasterMapScreen()
                              : GeminiMapScreen(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    items: const [
                      DropdownMenuItem(
                          value: "natural_disaster",
                          child: Text("Natural Disaster")),
                      DropdownMenuItem(
                          value: "humanitarian_conflict",
                          child: Text("Humanitarian Conflict")),
                      DropdownMenuItem(
                          value: "pandemic", child: Text("Pandemic")),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCategory = newValue;
                          isLoading = true;
                          fetchCrisisData();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isError
                          ? const Center(
                              child: Text('Failed to load crisis updates.'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: crises.length,
                              itemBuilder: (context, index) {
                                final crisis = crises[index];
                                return CrisisUpdateCard(
                                  title: crisis.title,
                                  description:
                                      '${crisis.runtimeType}: ${crisis.description}',
                                  category: crisis.runtimeType.toString(),
                                  timestamp: crisis.date,
                                  criticalLevel: crisis.criticalLevel,
                                  onTap: () {},
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return CommunityForum();
                  },
                ));
              },
              backgroundColor: Colors.blueAccent,
              child: const Icon(
                Icons.forum,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
