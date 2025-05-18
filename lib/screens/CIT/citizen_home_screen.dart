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
    CitizenAnnouncementsPollsScreen(),        // 0 - Announcements
    HomeScreen(),                              // 1 - Emergency
    ChatScreen(senderRole: "citizen"),         // 2 - Chat
    ReportFormScreen(),                        // 3 - Report
    AdFeedScreen(),                            // 4 - Ads
  ];

  void _handleNavigation(int index) {
    if (index < _screens.length) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6C4B0),
      body: Column(
        children: [
          const SizedBox(height: 30), // for status bar space
          // 🔼 Top Navigation Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                        icon: Icon(
                          Icons.message,
                          color: _currentIndex == 2 ? Colors.black : Colors.black45,
                        ),
                      ),
                      // Report
                      IconButton(
                        onPressed: () => _handleNavigation(3),
                        icon: Icon(
                          Icons.report,
                          color: _currentIndex == 3 ? Colors.black : Colors.black45,
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
