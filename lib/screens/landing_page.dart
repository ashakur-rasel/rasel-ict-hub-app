import 'package:flutter/material.dart';
import 'login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeIn,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHero(),
              _buildAboutSection(),
              _buildInstructorSection(),
              _buildStats(),
              _buildRoleSection(context),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // --- সব ডিজাইন মেথড নিচে দেওয়া হলো ---

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF020617)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Column(
        children: [
          Hero(
            tag: 'logo',
            child: Icon(Icons.hub_rounded, size: 100, color: Colors.cyanAccent),
          ),
          SizedBox(height: 20),
          Text(
            "ICT HUB",
            style: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.bold,
              letterSpacing: 5,
            ),
          ),
          Text(
            "FUTURE OF IT LEARNING",
            style: TextStyle(color: Colors.cyanAccent, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About Our Mission",
            style: TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "We are dedicated to providing high-quality IT education. From basic ICT to advanced programming, we empower students to lead the digital age.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.cyanAccent,
            child: Icon(Icons.person, size: 50, color: Colors.black),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Lead Instructor",
                style: TextStyle(color: Colors.cyanAccent, fontSize: 12),
              ),
              const Text(
                "Ashakur Rahman Rasel",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Business Analyst & SQA",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statBox("500+", "Students"),
          _statBox("50+", "Courses"),
          _statBox("100%", "Quality"),
        ],
      ),
    );
  }

  Widget _statBox(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.cyanAccent, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRoleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        children: [
          const Text(
            "Select Portal to Login",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 25),
          _roleButton(
            context,
            "STUDENT LOGIN",
            Icons.school,
            Colors.cyanAccent,
            "Student",
          ),
          const SizedBox(height: 15),
          _roleButton(
            context,
            "TEACHER PORTAL",
            Icons.admin_panel_settings,
            Colors.orangeAccent,
            "Teacher",
          ),
        ],
      ),
    );
  }

  Widget _roleButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String role,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(role: role, themeColor: color),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.05)],
          ),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
