import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:relieflink/login/loginscreen.dart';
import 'package:relieflink/login/splash_screen.dart';
import 'package:relieflink/models/donation/create_campaign_card.dart';
import 'package:relieflink/models/volunteer/add_announcements.dart';
import 'package:relieflink/models/volunteer/approve_volunteer.dart';
import 'package:relieflink/models/volunteer/volunteer_card_create.dart';
import 'package:relieflink/screens/transparency_screen.dart';
import 'package:relieflink/services/donation_service.dart';
import 'package:relieflink/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String createEmailShortForm(String email) {
    if (email.length < 7) {
      throw FormatException('Email should have at least 7 characters');
    }
    return '${email[0].toUpperCase()}${email[6].toUpperCase()}';
  }

  Future<int> fetchDonations() async {
    return await getTotalDonations();
  }

  @override
  Widget build(BuildContext context) {
    String shortform = createEmailShortForm(universalId);
    if (isNGO) {
      shortform = 'NGO';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: !logStatus,
                child: const SizedBox(height: 120.0),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Colors.blue,
                  child: Text(
                    (universalId != 'Sign Up/ Login to view details')
                        ? shortform
                        : '-',
                    style: const TextStyle(
                      fontSize: 32.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Text(
                  (universalId != 'Sign Up/ Login to view details')
                      ? universalId
                      : 'Sign Up/ Login to view details',
                  style: TextStyle(
                    fontSize: (universalId != 'Sign Up/ Login to view details')
                        ? 24.0
                        : 16.0,
                    fontWeight:
                        (universalId != 'Sign Up/ Login to view details')
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Visibility(
                visible: universalId == 'Sign Up/ Login to view details',
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                    );
                  },
                  child: Text('Login/Signup'.tr),
                ),
              ),
              const SizedBox(height: 24.0),

              // Donation stats
              Visibility(
                visible: logStatus && !isNGO,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Impact'.tr,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      FutureBuilder<int>(
                        future: fetchDonations(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error loading donations'.tr);
                          } else {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      snapshot.data.toString().tr,
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Total Donated'.tr,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      '15',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Donations'.tr,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      '8',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      'Organizations'.tr,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (ctx) => TransparencyScreen()),
                            );
                          },
                          child: Text('View Detailed Impact'.tr),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Visibility(
                visible: isNGO,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.volunteer_activism),
                      title: const Text('Create Campaign'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => CreateCampaignCard(
                              ngoEmail: universalId,
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Request Volunteers'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => CreateVolunteerCard(
                              ngoEmail: universalId,
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Approve Volunteers'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => ApproveVolunteer(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Add Announcements'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => AddAnnouncements(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.book),
                      title: const Text('Add Resources'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (ctx) => CreateVolunteerCard(
                        //       ngoEmail: universalId,
                        //     ),
                        //   ),
                        // );
                      },
                    ),
                  ],
                ),
              ),

              // Logout button
              Visibility(
                visible: logStatus,
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      bool shouldExit = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Log Out?".tr),
                          content: Text(
                              "You will be signed out of the application. Do you really want to log out?"
                                  .tr),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text("No".tr),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text("Yes".tr),
                            ),
                          ],
                        ),
                      );

                      if (shouldExit == true) {
                        await saveisNGOStatus(false);
                        await saveLoginStatus(false);
                        await saveIDStatus('Sign Up/ Login to view details');
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SplashScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    child: Text('Logout'.tr),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
