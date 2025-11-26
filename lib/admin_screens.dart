import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'login_screen.dart';
import 'app_theme.dart';
import 'services/auth_service.dart';
import 'services/book_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    try {
      final isAdmin = await AuthService.isAdmin();
      if (!mounted) return;
      
      setState(() {
        _isAdmin = isAdmin;
        _isChecking = false;
      });

      if (!isAdmin) {
        // Show access denied and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access Denied: Admin privileges required'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking admin access: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: const Color(0xFF2C2C2C),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFF2C2C2C),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.block, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Admin privileges required',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: _selectedIndex == 0
              ? const _AdminHomeList()
              : const AdminProfileScreen(),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}