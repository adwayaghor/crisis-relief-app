import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:relieflink/screens/forum_screen.dart';
import 'package:relieflink/screens/gemini_api.dart';

class AwarenessScreen extends StatefulWidget {
  AwarenessScreen({super.key});

  @override
  _AwarenessScreenState createState() => _AwarenessScreenState();
}

class _AwarenessScreenState extends State<AwarenessScreen> {
  String featuredTitle = "Loading...";
  String featuredSummary = "Please wait while we fetch the latest updates.";
  String featuredImage = "";
  List<Map<String, String>> resources = [];

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    try {
      String prompt = """
      Provide a JSON object with:
- A featured crisis awareness topic (title & summary).
- A working image URL from a **reliable source** (Unsplash, Wikimedia, Pexels, or NGOs like WFP, Red Cross, WHO).
- Ensure the URL points to an **actual image** (JPG, PNG).
    Example:
    {
      "featured": {
        "title": "The Global Food Crisis",
        "summary": "Millions face acute food insecurity due to conflict, climate change, and economic instability.",
        "image": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/WFP_Food_Distribution.jpg"
      }
    }
    Return ONLY a valid JSON response with no additional text.
      Also, list 5 educational resources related to humanitarian crises (title and type - article, video, podcast, etc.).
        "resources": [
          {"title": "How Humanitarian Aid Works", "type": "Article"},
          {"title": "Refugee Crisis Explained", "type": "Video"},
          {"title": "Disaster Response Mechanisms", "type": "Podcast"},
          {"title": "Role of NGOs in Crisis Situations", "type": "Infographic"},
          {"title": "Climate Change and Disasters", "type": "Interactive"}
        ]
      }
      """;

      final String response = await GeminiService.generateText(prompt);
      final cleanedResponse =
          response.replaceAll(RegExp(r'```json|```'), '').trim();
      final Map<String, dynamic> jsonData = jsonDecode(cleanedResponse);

      setState(() {
        featuredTitle = jsonData['featured']['title'];
        featuredSummary = jsonData['featured']['summary'];
        featuredImage = jsonData['featured']['image']?.toString() ??
            "https://via.placeholder.com/400";
        resources = (jsonData['resources'] as List)
            .map((item) => {
                  "title": item["title"].toString(),
                  "type": item["type"].toString(),
                })
            .toList();
      });
    } catch (e) {
      print("❌ Error fetching content: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Learn & Share'.tr),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Education & Awareness'.tr,
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Learn about humanitarian crises and share knowledge'.tr,
                    style: TextStyle(color: Colors.grey[700], fontSize: 16.0),
                  ),
                  const SizedBox(height: 24.0),
                  _buildFeaturedContentCard(),
                  const SizedBox(height: 24.0),
                  _buildEducationalResources(),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return CommunityForum();
                }));
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

  Widget _buildFeaturedContentCard() {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180.0,
            width: double.infinity,
            decoration: BoxDecoration(
              image: featuredImage.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(featuredImage), fit: BoxFit.cover)
                  : null,
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(featuredTitle.tr,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8.0),
                Text(featuredSummary.tr,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14.0)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalResources() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.article, color: Colors.blueAccent),
          title: Text(resources[index]['title']!.tr),
          subtitle: Text(resources[index]['type']!.tr),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
        );
      },
    );
  }
}
