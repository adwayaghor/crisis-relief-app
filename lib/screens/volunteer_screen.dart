import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:relieflink/models/volunteer/volunteer_details.dart';
import 'package:relieflink/models/volunteer/your_volunteer.dart';
import 'package:relieflink/shared_preferences.dart';

class VolunteerScreen extends StatefulWidget {
  const VolunteerScreen({super.key});

  @override
  State<VolunteerScreen> createState() => _VolunteerScreenState();
}

class _VolunteerScreenState extends State<VolunteerScreen> {
  List<Map<String, dynamic>> volunteerCampaigns = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCampaigns();
  }

  Future<void> fetchCampaigns() async {
    final url = Uri.parse(
        'https://relieflink-e824d-default-rtdb.firebaseio.com/volunteer.json');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);
        if (data != null) {
          setState(() {
            volunteerCampaigns = data.entries
                .map((entry) => entry.value as Map<String, dynamic>)
                .toList();
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load Volunteer Campaigns');
      }
    } catch (error) {
      print('Error fetching campaigns: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Volunteering Campaigns".tr),
        backgroundColor: const Color(0xFF2D7DD2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Visibility(
                visible: logStatus,
                child: Text(
                      'You Volunteered in'.tr,
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
              ),
              Visibility(
                visible: logStatus,
                child: ListTile(
                        leading: const Icon(Icons.people),
                        title: Text('View'.tr),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => YourVolunteer()
                            ),
                          );
                        },
                      ),
              ),
              Text(
                    'Featured Campaigns'.tr,
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Placeholder for volunteer campaign cards
                   
                      const SizedBox(height: 16.0),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: volunteerCampaigns.map((campaign) {
                                return Column(
                                  children: [
                                    VolunteerDetails(
                                      title: campaign['campaignName'],
                                      organization: campaign['ngoEmail'],
                                      target: (campaign['volunteers']),
                                      description: (campaign['description']),
                                      imageUrl: campaign['imageUrl'] ?? 'https://educationpost.in/_next/image?url=https%3A%2F%2Fapi.educationpost.in%2Fs3-images%2F1736253267338-untitled%20(39).jpg&w=1920&q=75',
                                    ),
                                    const SizedBox(height: 16.0),
                                  ],
                                );
                              }).toList(),
                            ),
                      const SizedBox(height: 24.0),
              
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
