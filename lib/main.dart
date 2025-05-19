import 'package:continuehayygov/screens/auth_page_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './providers/auth_provider.dart';
import './screens/login_screen.dart';
import './screens/CIT/citizen_home_screen.dart';
import './screens/AD/advertiser_dashboard_screen.dart';
import 'firebase_options.dart';
import './screens/GOV/government_main_screen.dart';
import 'services/notification_service.dart'; // ✅ NEW

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); // ✅ NEW

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
  } catch (e) {}

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().init(); // ✅ NEW

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'HayyGov',
        theme: ThemeData(primarySwatch: Colors.red),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey, // ✅ NEW
        routes: {
          '/': (context) => const AuthPageView(),
          '/citizenHome': (context) => const CitizenHomeScreen(),
          '/govHome': (context) => const GovernmentMainScreen(),
          '/advertiserDashboard': (context) => const AdvertiserDashboardScreen(),
        },
      ),
    );
  }
}
