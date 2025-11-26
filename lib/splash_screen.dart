import 'package:flutter/material.dart';
import 'click_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool shouldNavigate;

  const SplashScreen({super.key, this.shouldNavigate = true});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.shouldNavigate) {
      _navigateToHome();
    }
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    if (mounted && widget.shouldNavigate) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClickScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Book icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.menu_book,
                  size: 60,
                  color: Color(0xFF1E3A8A),
                ),
              ),

              const SizedBox(height: 30),

              // READAURA text
              const Text(
                'READAURA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 10),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
