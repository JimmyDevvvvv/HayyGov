import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../GOV/announcement_feed_screen.dart';
import '../GOV/polls_section.dart';
import '../GOV/emergency_n.dart';
import '../report/report_list_screen.dart';

class AdApprovalScreen extends StatefulWidget {
  const AdApprovalScreen({super.key});

  @override
  State<AdApprovalScreen> createState() => _AdApprovalScreenState();
}

class _AdApprovalScreenState extends State<AdApprovalScreen> {
  String? approvedAdId;
  String? rejectedAdId;

  bool showAds = true; // For the switch

  Future<void> _approveAd(String adId) async {
    await FirebaseFirestore.instance.collection('ads').doc(adId).update({
      'approved': true,
    });
    setState(() {
      approvedAdId = adId;
      rejectedAdId = null;
    });
  }

  Future<void> _deleteAd(String adId) async {
    await FirebaseFirestore.instance.collection('ads').doc(adId).delete();
    setState(() {
      rejectedAdId = adId;
      approvedAdId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unapprovedAdsRef = FirebaseFirestore.instance
        .collection('ads')
        .where('approved', isEqualTo: false)
        .orderBy('timestamp', descending: true);

    final Color bgColor = const Color(0xFFF2E9E1);
    final Color navBrown = const Color(0xFF9C7B4B);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Approve Advertisements"),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: bgColor,
      body: Column(
        children: [
          // --- HayyGov Header with navigation bar ---
          Container(
            margin: const EdgeInsets.fromLTRB(12, 18, 12, 0),
            decoration: BoxDecoration(
              color: navBrown,
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/header_bg.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0xFF9C7B4B),
                  BlendMode.srcATop,
                ),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          "HayyGov",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Colors.black12,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: navBrown,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Announcements
                            IconButton(
                              icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 32),
                              tooltip: 'Announcements',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AnnouncementFeedScreen()),
                                );
                              },
                            ),
                            // Polls
                            IconButton(
                              icon: const Icon(Icons.poll, color: Colors.white, size: 32),
                              tooltip: 'Polls',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PollsSection()),
                                );
                              },
                            ),
                            // Emergency
                            IconButton(
                              icon: const Icon(Icons.call, color: Colors.red, size: 32),
                              tooltip: 'Emergency',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EmergencyN()),
                                );
                              },
                            ),
                            // Reports
                            IconButton(
                              icon: const Icon(Icons.description, color: Colors.white, size: 32),
                              tooltip: 'Reports',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ReportListScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // --- Switch between Ads and Emergency Numbers ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: Container(
              width: 240,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    alignment: showAds ? Alignment.centerRight : Alignment.centerLeft,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 120,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBDBDBD),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (showAds) {
                              setState(() {
                                showAds = false;
                              });
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const EmergencyN()),
                              );
                            }
                          },
                          child: Center(
                            child: Icon(
                              Icons.call,
                              color: showAds ? Colors.black : Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!showAds) {
                              setState(() {
                                showAds = true;
                              });
                              // Already on Ads page, do nothing
                            }
                          },
                          child: Center(
                            child: Icon(
                              Icons.check_circle,
                              color: showAds ? Colors.white : Colors.black,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // --- End Switch ---
          // --- End HayyGov Header ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: unapprovedAdsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text("No ads awaiting approval."));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final adId = docs[index].id;
                    final title = data['title'];
                    final desc = data['description'];
                    final imageUrl = data['imageUrl'];
                    final location = data['location'] ?? '';
                    final advertiserId = data['advertiserId'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(advertiserId).get(),
                      builder: (context, userSnapshot) {
                        String advertiserEmail = advertiserId;
                        if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData) {
                          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                          if (userData != null && userData.containsKey('email')) {
                            advertiserEmail = userData['email'];
                          }
                        }

                        final isApproved = approvedAdId == adId;
                        final isRejected = rejectedAdId == adId;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFD6CFC7), width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: status icon, title, image
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Status icon
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0, right: 4.0),
                                      child: isApproved
                                          ? const Icon(Icons.check_circle, color: Colors.green, size: 26)
                                          : isRejected
                                              ? const Icon(Icons.cancel, color: Colors.red, size: 26)
                                              : const SizedBox(width: 26),
                                    ),
                                    const SizedBox(width: 2),
                                    // Title and desc
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            desc ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 15),
                                          ),
                                          if (location.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(location, style: const TextStyle(color: Colors.grey)),
                                                ],
                                              ),
                                            ),
                                          Text(
                                            'Advertiser: $advertiserEmail',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Image
                                    if (imageUrl != null && imageUrl.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const SizedBox(width: 80, height: 80),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Approve/Reject buttons row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Approve button
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isApproved ? Colors.black : Colors.transparent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        color: isApproved ? Colors.green.withOpacity(0.12) : Colors.transparent,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.thumb_up,
                                          color: Colors.green, // Always green
                                          size: 32,
                                        ),
                                        onPressed: () => _approveAd(adId),
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    // Reject button
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isRejected ? Colors.black : Colors.transparent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        color: isRejected ? Colors.red.withOpacity(0.12) : Colors.transparent,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.thumb_down,
                                          color: Colors.red, // Always red
                                          size: 32,
                                        ),
                                        onPressed: () => _deleteAd(adId),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}