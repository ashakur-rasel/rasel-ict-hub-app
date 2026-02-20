import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? userData;
  Map<String, dynamic>? stats;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userData = jsonDecode(prefs.getString('userData') ?? '{}');
    });
    _fetchStats();
    _animController.forward();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://rasel-ict-hub.vercel.app/api/student/dashboard-stats',
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          stats = jsonDecode(response.body)['stats'];
        });
      }
    } catch (e) {
      debugPrint("Stats error: $e");
    }
  }

  // --- সলিড লগআউট ফাংশন ---
  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "TERMINATE SESSION?",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to log out from the Secure Portal?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // ১. লোকাল স্টোরেজ ক্লিয়ার

              if (mounted) {
                setState(() {
                  userData = null; // ২. বর্তমান পেজ স্টেট ক্লিয়ার
                  stats = null;
                });
                // ৩. অ্যাপ রিস্টার্ট ভাইব দিতে রুট ক্লিয়ার করে ল্যান্ডিংয়ে পাঠানো
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: const Text("LOGOUT", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617), // Slate-950
      body: userData == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildStatsGrid(),
                    const SizedBox(height: 30),
                    const Text(
                      "QUICK_ACCESS_MENU",
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        letterSpacing: 2,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildModernMenu(),
                  ],
                ),
              ),
            ),
    );
  }

  // --- ১. হেডার সেকশন ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "DASHBOARD_CORE",
              style: TextStyle(
                color: Colors.cyanAccent,
                letterSpacing: 2,
                fontSize: 12,
              ),
            ),
            Text(
              userData?['name'] ?? "User",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') _handleLogout();
          },
          offset: const Offset(0, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: const Color(0xFF1E293B),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: ListTile(
                leading: Icon(Icons.person_outline, color: Colors.cyanAccent),
                title: Text(
                  "My Profile",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: ListTile(
                leading: Icon(
                  Icons.power_settings_new,
                  color: Colors.redAccent,
                ),
                title: Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
          child: _buildProfileIcon(),
        ),
      ],
    );
  }

  Widget _buildProfileIcon() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.cyanAccent,
      ),
      child: const CircleAvatar(
        radius: 25,
        backgroundColor: Color(0xFF020617),
        child: Icon(Icons.person, color: Colors.cyanAccent),
      ),
    );
  }

  // --- ২. অ্যানিমেটেড স্ট্যাটাস কার্ডস ---
  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _statCard(
          "ATTENDANCE",
          "${stats?['attendance'] ?? '0'}%",
          Icons.bolt,
          Colors.greenAccent,
        ),
        _statCard(
          "LESSONS",
          "${stats?['totalLessons'] ?? '0'}",
          Icons.menu_book,
          Colors.blueAccent,
        ),
        _statCard(
          "TASKS",
          "${stats?['assignments'] ?? '0'}",
          Icons.task_alt,
          Colors.orangeAccent,
        ),
        _statCard("RANK", "A+", Icons.star, Colors.purpleAccent),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  // --- ৩. মডার্ন অ্যানিমেটেড মেনু ---
  Widget _buildModernMenu() {
    return Column(
      children: [
        _menuItem(
          "STUDY_HUB",
          "Access your lessons",
          Icons.auto_stories,
          Colors.cyanAccent,
          onTap: () {
            debugPrint("Study Hub Clicked");
            // Navigator.push(context, MaterialPageRoute(builder: (context) => StudyHubScreen()));
          },
        ),
        _menuItem(
          "LIVE_EXAM",
          "Upcoming assessments",
          Icons.rocket_launch,
          Colors.pinkAccent,
        ),
        _menuItem(
          "RESOURCES",
          "Download materials",
          Icons.cloud_download,
          Colors.amberAccent,
        ),
        _menuItem(
          "SUPPORT",
          "Contact instructor",
          Icons.support_agent,
          Colors.blueAccent,
        ),
      ],
    );
  }

  Widget _menuItem(
    String title,
    String sub,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.transparent],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.white.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}
