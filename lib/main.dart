import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/landing_page.dart';
import 'screens/student_dashboard.dart';
import 'screens/admin_dashboard.dart';

void main() async {
  // ১. ফ্লাটার ইঞ্জিন ইনিশিয়ালাইজ করা
  WidgetsFlutterBinding.ensureInitialized();

  // ২. ফায়ারবেস সেটআপ
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ৩. সেশন ডাটা রিড করা
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String? userRole = prefs.getString('userRole');

  // ৪. সেশনের ওপর ভিত্তি করে গন্তব্য ঠিক করা (Null Safety নিশ্চিত করে)
  Widget initialScreen;

  if (isLoggedIn && userRole != null) {
    // এখানে const সরানো হয়েছে কারণ ড্যাশবোর্ডগুলো ডাইনামিক
    initialScreen = (userRole == 'admin')
        ? AdminDashboard()
        : StudentDashboard();
  } else {
    initialScreen = const LandingPage();
  }

  // ৫. এখন অ্যাপ রান করা, যেখানে home কখনোই null হবে না
  runApp(RaselICTHubApp(startWidget: initialScreen));
}

class RaselICTHubApp extends StatelessWidget {
  final Widget startWidget;
  const RaselICTHubApp({super.key, required this.startWidget});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ICT HUB',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617), // Slate-950
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF22D3EE)),
      ),
      // home এ সরাসরি সলিড উইজেট যাচ্ছে
      home: startWidget,
      // রুট ম্যাপ (লগআউট কল করার জন্য)
      routes: {'/landing': (context) => const LandingPage()},
    );
  }
}
