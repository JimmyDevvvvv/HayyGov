import 'package:flutter/material.dart';
import 'emergency_n.dart';
import 'citizen_announcements_polls_screen.dart';
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
    CitizenAnnouncementsPollsScreen(), // 0
    HomeScreen(),                      // 1
    const SizedBox.shrink(),          // 2 - Chat
    const SizedBox.shrink(),          // 3 - Report
    const AdFeedScreen(),             // 4
  ];

  void _handleNavigation(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChatScreen(senderRole: "citizen"),
        ),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ReportFormScreen(),
        ),
      );
    } else if (index < _screens.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(221, 203, 183, 1),
      body: Column(
        children: [
          const SizedBox(height: 30), // for status bar space
          // 🔼 Top Navigation Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/images/bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Stack(
                children: [
                  // White overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  // Navigation Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Announcements
                      IconButton(
                        onPressed: () => _handleNavigation(0),
                        icon: Icon(
                          Icons.campaign,
                          color: _currentIndex == 0 ? Colors.black : Colors.black45,
                        ),
                      ),
                      // Emergency
                      IconButton(
                        onPressed: () => _handleNavigation(1),
                        icon: Icon(
                          Icons.phone,
                          color: _currentIndex == 1 ? Colors.black : Colors.black45,
                        ),
                      ),
                      // Title
                      const Text(
                        'HayyGov',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 2,
                        ),
                      ),
                      // Message
                      IconButton(
                        onPressed: () => _handleNavigation(2),
                        icon: const Icon(
                          Icons.message,
                          color: Colors.black,
                        ),
                      ),
                      // Report
                      IconButton(
                        onPressed: () => _handleNavigation(3),
                        icon: const Icon(
                          Icons.report,
                          color: Colors.black,
                        ),
                      ),
                      // Ads
                      IconButton(
                        onPressed: () => _handleNavigation(4),
                        icon: Icon(
                          Icons.local_offer,
                          color: _currentIndex == 4 ? Colors.black : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 🔽 Screen content
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
    );
  }
}
