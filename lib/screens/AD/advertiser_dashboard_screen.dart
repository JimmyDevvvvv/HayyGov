import 'package:flutter/material.dart';
import 'create_ad_screen.dart';
import 'my_ads_screen.dart';

class AdvertiserDashboardScreen extends StatefulWidget {
  const AdvertiserDashboardScreen({super.key});

  @override
  State<AdvertiserDashboardScreen> createState() => _AdvertiserDashboardScreenState();
}

class _AdvertiserDashboardScreenState extends State<AdvertiserDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CreateAdScreen(),
    const MyAdsScreen(),
  ];

  void _handleNavigation(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE6DC),
      body: Column(
        children: [
          const SizedBox(height: 30), // Status bar spacing
          // 🔼 Custom Top Navigation
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
                      // Create Ad with extra left padding
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: IconButton(
                          onPressed: () => _handleNavigation(0),
                          iconSize: 32,
                          icon: Icon(
                            Icons.post_add,
                            color: _currentIndex == 0 ? Colors.black : Colors.black45,
                          ),
                        ),
                      ),
                      const Text(
                        'HayyGov - Advertiser',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 2,
                        ),
                      ),
                      // My Ads with extra right padding
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: IconButton(
                          onPressed: () => _handleNavigation(1),
                          iconSize: 32,
                          icon: Icon(
                            Icons.edit_note,
                            color: _currentIndex == 1 ? Colors.black : Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 🔽 Screen content
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
    );
  }
}
