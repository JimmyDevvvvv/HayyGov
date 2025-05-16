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
    const CreateAdScreen(), // Create Ad
    const MyAdsScreen(),    // View/Edit/Delete Ads
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advertiser Dashboard'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Create Ad'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'My Ads'),
        ],
      ),
    );
  }
}
