import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:relieflink/main.dart';
import 'dart:convert';
import 'package:relieflink/models/crisis_update_card.dart';
import 'package:relieflink/screens/ai_map_screen.dart';
import 'package:relieflink/screens/forum_screen.dart';
import 'package:relieflink/screens/maps_screen.dart';
import 'package:relieflink/screens/gemini_api.dart';
import 'package:relieflink/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Factory constructor to create Crisis objects from Gemini API JSON
  static Crisis fromGeminiJson(Map<String, dynamic> json) {
    final type = json['type'] ?? 'Unknown';

    if (type.toLowerCase().contains('natural') ||
        ['earthquake', 'flood', 'hurricane', 'tsunami', 'wildfire', 'volcano']
            .any((t) => type.toLowerCase().contains(t))) {
      return NaturalDisaster(
        title: json['title'] ?? 'No Title',
        description: json['description'] ?? 'No Description Available',
        disasterType: json['type'] ?? 'Unknown',
        country: json['location'] ?? 'Unknown Location',
        date: json['date'] ?? DateTime.now().toString(),
        criticalLevel: json['severity'] ?? 'Medium',
      );
    } else if (type.toLowerCase().contains('conflict') ||
        type.toLowerCase().contains('humanitarian')) {
      return HumanitarianCrisis(
        title: json['title'] ?? 'No Title',
        description: json['description'] ?? 'No Description Available',
        crisisType: json['type'] ?? 'Unknown',
        country: json['location'] ?? 'Unknown Location',
        date: json['date'] ?? DateTime.now().toString(),
        criticalLevel: json['severity'] ?? 'Medium',
      );
    } else if (type.toLowerCase().contains('disease') ||
        type.toLowerCase().contains('pandemic') ||
        type.toLowerCase().contains('outbreak')) {
      return HealthCrisis(
        title: json['title'] ?? 'No Title',
        description: json['description'] ?? 'No Description Available',
        diseaseType: json['type'] ?? 'Unknown',
        country: json['location'] ?? 'Unknown Location',
        date: json['date'] ?? DateTime.now().toString(),
        criticalLevel: json['severity'] ?? 'Medium',
      );
    } else {
      // Default to NaturalDisaster if type is unclear
      return NaturalDisaster(
        title: json['title'] ?? 'No Title',
        description: json['description'] ?? 'No Description Available',
        disasterType: 'Unspecified',
        country: json['location'] ?? 'Unknown Location',
        date: json['date'] ?? DateTime.now().toString(),
        criticalLevel: json['severity'] ?? 'Medium',
      );
    }
  }
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

class HumanitarianCrisis extends Crisis {
  final String crisisType;

  HumanitarianCrisis({
    required super.title,
    required super.description,
    required this.crisisType,
    required super.country,
    required super.date,
    required super.criticalLevel,
  });
}

class HealthCrisis extends Crisis {
  final String diseaseType;

  HealthCrisis({
    required super.title,
    required super.description,
    required this.diseaseType,
    required super.country,
    required super.date,
    required super.criticalLevel,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Crisis> crises = [];
  bool isLoading = true;
  bool isError = false;
  String selectedCategory = "natural_disaster";
  int _currentPage = 0; // Track current page index

  // Add a state variable for the selected language
  String selectedLanguage = "English";

  @override
  void initState() {
    super.initState();
    loadSavedLanguage();
    fetchCrisisData();
  }

  Future<void> loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedLang = prefs.getString('language') ?? 'English';
    setState(() {
      selectedLanguage = savedLang;
    });
    Get.updateLocale(Locale(getLocaleCode(savedLang)));
  }

  Future<void> fetchCrisisData() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    String prompt;
    if (selectedCategory == "natural_disaster") {
      prompt = """
        Provide a JSON object containing the latest 5 natural disasters happening around the world.
        Include data from official sources like Red Cross, WHO, UN, and government agencies.
        Only return a valid JSON object with no additional text.
        Example format:
        {
          "crises": [
            {
              "title": "7.2 Magnitude Earthquake in Turkey",
              "description": "A powerful earthquake struck eastern Turkey causing widespread damage and casualties.",
              "type": "Earthquake",
              "location": "Turkey",
              "date": "2025-03-01",
              "severity": "High",
              "source": "UN OCHA"
            }
          ]
        }
      """;
    } else if (selectedCategory == "humanitarian_conflict") {
      prompt = """
        Provide a JSON object containing the latest 5 humanitarian crises and conflicts happening around the world.
        Include data from official sources like Red Cross, WHO, UN, and government agencies.
        Only return a valid JSON object with no additional text.
        Example format:
        {
          "crises": [
            {
              "title": "Refugee Crisis in Eastern Europe",
              "description": "Mass displacement of people due to regional conflict with inadequate humanitarian support.",
              "type": "Humanitarian Crisis",
              "location": "Ukraine-Moldova Border",
              "date": "2025-02-28",
              "severity": "Critical",
              "source": "UNHCR"
            }
          ]
        }
      """;
    } else {
      prompt = """
        Provide a JSON object containing the latest 5 disease outbreaks and health emergencies happening around the world.
        Include data from official sources like WHO, CDC, Red Cross, and health ministries.
        Only return a valid JSON object with no additional text.
        Example format:
        {
          "crises": [
            {
              "title": "Dengue Fever Outbreak in Southeast Asia",
              "description": "Rising cases of dengue fever reported across multiple countries with strained healthcare systems.",
              "type": "Disease Outbreak",
              "location": "Thailand, Vietnam, Philippines",
              "date": "2025-02-15",
              "severity": "High",
              "source": "WHO"
            }
          ]
        }
      """;
    }

    try {
      final String response = await GeminiService.generateText(prompt);
      final String cleanedResponse =
          response.replaceAll(RegExp(r'```json|```'), '').trim();

      final Map<String, dynamic> jsonData = jsonDecode(cleanedResponse);

      if (jsonData.containsKey("crises")) {
        setState(() {
          crises = (jsonData["crises"] as List)
              .map((crisis) => Crisis.fromGeminiJson(crisis))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception("Invalid JSON format: missing 'crises' key");
      }
    } catch (e) {
      print('Error fetching crisis data from Gemini: $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crisis Dashboard'.tr,),
        actions: [
          // Replace the IconButton with a DropdownButton for language selection
          DropdownButton<String>(
            icon: const Icon(Icons.language, color: Colors.black), 
            value: selectedLanguage,
            onChanged: (String? newValue) async {
              if (newValue != null) {
                setState(() {
                  selectedLanguage = newValue;
                });

                // Save language preference
                await saveLangStatus(newValue);

                // Update app locale
                Get.updateLocale(Locale(getLocaleCode(newValue)));
              }
            },
            items: const [
              DropdownMenuItem(value: "English", child: Text("English")),
              DropdownMenuItem(value: "Hindi", child: Text("Hindi")),
              DropdownMenuItem(value: "Marathi", child: Text("Marathi")),
              DropdownMenuItem(value: "Tamil", child: Text("Tamil")),
              DropdownMenuItem(value: "Kannada", child: Text("Kannada")),
              DropdownMenuItem(value: "German", child: Text("German")),
              DropdownMenuItem(value: "French", child: Text("French")),
              DropdownMenuItem(value: "Japanese", child: Text("Japanese")),
              DropdownMenuItem(value: "Chinese", child: Text("Chinese")),
              DropdownMenuItem(value: "Korean", child: Text("Korean")),
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _currentPage == 0
                        ? 'Urgent Crises'.tr
                        : 'Predicted Crises'.tr,
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
                          Expanded(
                            child: ElevatedButton(
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
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text('Urgent Crises'.tr),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
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
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text('Predicted Crises'.tr),
                              ),
                            ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        value: selectedCategory,
                        items: [
                          DropdownMenuItem(
                              value: "natural_disaster",
                              child: Text("Natural Disaster".tr)),
                          DropdownMenuItem(
                              value: "humanitarian_conflict",
                              child: Text("Humanitarian Conflict".tr)),
                          DropdownMenuItem(
                              value: "pandemic", child: Text("Pandemic".tr)),
                        ],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedCategory = newValue;
                              fetchCrisisData();
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: fetchCrisisData,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isError
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Failed to load crisis updates.'.tr),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: fetchCrisisData,
                                    child: Text('Try Again'.tr),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: crises.length,
                              itemBuilder: (context, index) {
                                final crisis = crises[index];
                                String categoryType = 'Unknown';

                                if (crisis is NaturalDisaster) {
                                  categoryType = crisis.disasterType;
                                } else if (crisis is HumanitarianCrisis) {
                                  categoryType = crisis.crisisType;
                                } else if (crisis is HealthCrisis) {
                                  categoryType = crisis.diseaseType;
                                }

                                return CrisisUpdateCard(
                                  title: crisis.title,
                                  description: crisis.description,
                                  category: categoryType,
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
