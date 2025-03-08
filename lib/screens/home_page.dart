import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:relieflink/screens/awareness_screen.dart';
import 'package:relieflink/screens/dashboard_screen.dart';
import 'package:relieflink/screens/donation_screen.dart';
import 'package:relieflink/screens/profile_screen.dart';
import 'package:relieflink/screens/volunteer_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const DonationScreen(),
    const VolunteerScreen(),
    AwarenessScreen(),
    const ProfileScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2D7DD2),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Donate'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Volunteer'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Awareness'.tr,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile'.tr,
          ),
        ],
      ),
    );
  }
}