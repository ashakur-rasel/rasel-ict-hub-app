import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // সেশন সেভ করার জন্য
import 'student_dashboard.dart'; // এই ফাইলগুলো তৈরি করতে হবে
import 'admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  final String role;
  final Color themeColor;
  const LoginPage({super.key, required this.role, required this.themeColor});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _rocketController;
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _rocketController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _rocketController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _showNotification(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final String userInput = _userController.text.trim();
    final String password = _passController.text.trim();

    if (userInput.isEmpty || password.isEmpty) {
      _showNotification("SYSTEM ERROR: CREDENTIALS REQUIRED", Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);
    _rocketController.forward();

    try {
      String apiRole = widget.role.toLowerCase() == "teacher"
          ? "admin"
          : "student";
      final url = Uri.parse('https://rasel-ict-hub.vercel.app/api/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': userInput,
          'password': password,
          'role': apiRole,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // --- সেশন সেভ করা (LocalStorage এর মতো) ---
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userRole', apiRole);
        await prefs.setString('userData', jsonEncode(data['user']));

        _rocketController.reverse().then((_) {
          _showNotification(
            "ACCESS GRANTED: WELCOME ${data['user']['name'].toString().toUpperCase()}",
            Colors.green,
          );

          // --- ড্যাশবোর্ডে নেভিগেশন ---
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  apiRole == "admin" ? AdminDashboard() : StudentDashboard(),
            ),
          );
        });
      } else {
        _rocketController.reverse();
        _showNotification(
          data['message'] ?? "ACCESS DENIED: INVALID CREDENTIALS",
          Colors.redAccent,
        );
      }
    } catch (e) {
      _rocketController.reverse();
      _showNotification("SYSTEM ERROR: SERVER UNREACHABLE", Colors.redAccent);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
          color: widget.themeColor,
        ),
        title: Text(
          "${widget.role.toUpperCase()} PORTAL",
          style: TextStyle(
            color: widget.themeColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _rocketController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_rocketController.value * 120),
                  child: Hero(
                    tag: 'logo',
                    child: Icon(
                      Icons.rocket_launch,
                      size: 80,
                      color: widget.themeColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _userController,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.green,
              ),
              decoration: InputDecoration(
                labelText: "EMAIL OR PHONE",
                labelStyle: TextStyle(
                  color: widget.themeColor.withOpacity(0.5),
                ),
                prefixIcon: Icon(Icons.person, color: widget.themeColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.themeColor.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.themeColor),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passController,
              obscureText: _isObscure,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.green,
              ),
              decoration: InputDecoration(
                labelText: "ACCESS CODE",
                labelStyle: TextStyle(
                  color: widget.themeColor.withOpacity(0.5),
                ),
                prefixIcon: Icon(Icons.lock, color: widget.themeColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                    color: widget.themeColor,
                  ),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.themeColor.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.themeColor),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.themeColor,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                      "INITIATE LOGIN",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
