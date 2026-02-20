import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? adminData;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminData = jsonDecode(prefs.getString('userData') ?? '{}');
    });
  }

  // --- সলিড অ্যাডমিন লগআউট ফাংশন ---
  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "TERMINATE ADMIN SESSION?",
          style: TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Security check: Do you want to sign out from the Admin Control Panel?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orangeAccent,
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // ১. লোকাল স্টোরেজ ক্লিয়ার

              if (mounted) {
                setState(() {
                  adminData = null; // ২. বর্তমান স্টেট ক্লিনিং
                });
                // ৩. রুট ক্লিয়ার করে ল্যান্ডিং পেজে পাঠানো
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: const Text(
              "SECURE LOGOUT",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617), // Slate-950
      body: adminData == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildSystemStats(),
                    const SizedBox(height: 30),
                    const Text(
                      "ADMINISTRATION_CORE",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        letterSpacing: 2,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildAdminMenu(),
                  ],
                ),
              ),
            ),
    );
  }

  // --- ১. অ্যাডমিন হেডার (Logout পপআপ সহ) ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "SYSTEM_ADMIN_ACCESS",
              style: TextStyle(
                color: Colors.orangeAccent,
                letterSpacing: 1.5,
                fontSize: 10,
              ),
            ),
            Text(
              adminData?['name'] ?? "Admin",
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
              value: 'logout',
              child: ListTile(
                leading: Icon(
                  Icons.power_settings_new,
                  color: Colors.orangeAccent,
                ),
                title: Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
          child: _buildAdminProfileIcon(),
        ),
      ],
    );
  }

  Widget _buildAdminProfileIcon() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.orangeAccent,
      ),
      child: const CircleAvatar(
        radius: 25,
        backgroundColor: Color(0xFF020617),
        child: Icon(Icons.security, color: Colors.orangeAccent),
      ),
    );
  }

  // --- ২. সিস্টেম স্ট্যাটাস কার্ডস ---
  Widget _buildSystemStats() {
    return Row(
      children: [
        _statBox("USERS", "500", Icons.people_outline, Colors.blueAccent),
        const SizedBox(width: 15),
        _statBox(
          "LIVE_EXAMS",
          "03",
          Icons.rocket_launch_outlined,
          Colors.purpleAccent,
        ),
      ],
    );
  }

  Widget _statBox(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
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
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ৩. অ্যাডমিন মেনু (Next.js ফিচার অনুযায়ী) ---
  Widget _buildAdminMenu() {
    return Column(
      children: [
        _menuTile(
          "USER_MANAGEMENT",
          "Handle students & teachers",
          Icons.group_add,
          Colors.blueAccent,
          onTap: () => debugPrint("Manage Users Clicked"),
        ),
        _menuTile(
          "BROADCAST_HUB",
          "Send notifications to all",
          Icons.podcasts,
          Colors.orangeAccent,
          onTap: () => debugPrint("Broadcast Clicked"),
        ),
        _menuTile(
          "ATTENDANCE_LOGS",
          "Review daily attendance",
          Icons.fact_check,
          Colors.greenAccent,
          onTap: () => debugPrint("Attendance Clicked"),
        ),
        _menuTile(
          "ACADEMIC_RESOURCES",
          "Manage study materials",
          Icons.folder_copy,
          Colors.amberAccent,
          onTap: () => debugPrint("Resources Clicked"),
        ),
      ],
    );
  }

  Widget _menuTile(
    String title,
    String sub,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          sub,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5)),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.white24,
        ),
        onTap: onTap,
      ),
    );
  }
}
