import 'package:flutter/material.dart';
import 'emergencyN.dart';
import 'announcement_feed_screen.dart';
import 'voting_screen.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    AnnouncementFeedScreen(),
    VotingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Emergency'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Announcements'),
          BottomNavigationBarItem(icon: Icon(Icons.poll), label: 'Polls'),
        ],
      ),
    );
  }
}
