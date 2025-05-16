import 'package:flutter/material.dart';
import 'emergencyN.dart';
import 'announcement_feed_screen.dart';
import 'voting_screen.dart';
import '../messaging/chat_screen.dart';
import '../report/report_form_screen.dart';
import '../AD/ad_feed_screen.dart';

class CitizenHomeScreen extends StatefulWidget {
  const CitizenHomeScreen({super.key});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),                     // 0 - Emergency
    AnnouncementFeedScreen(),        // 1 - Announcements
    VotingScreen(),                  // 2 - Polls
    const SizedBox.shrink(),         // 3 - Chat (push screen)
    const SizedBox.shrink(),         // 4 - Report (push screen)
    const AdFeedScreen(),            // 5 - Ads (approved only)
  ];

  void _handleNavigation(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatScreen(senderRole: "citizen"),
        ),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ReportFormScreen(),
        ),
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Emergency'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Announcements'),
          BottomNavigationBarItem(icon: Icon(Icons.poll), label: 'Polls'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Message'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: 'Ads'),
        ],
      ),
    );
  }
}
