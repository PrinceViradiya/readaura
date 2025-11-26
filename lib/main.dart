import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splash_screen.dart';
import 'main_app_screen.dart';
import 'admin_screens.dart';
import 'services/auth_service.dart';
import 'app_theme.dart';
import 'click_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey:
            "AIzaSyAuGvICPkV2nEi6mtlrGpxoEhWjCK6kbjI", // You'll get this from google-services.json
        appId: "1:517379996819:android:0061ffb4b93ecb66c1a166",
        messagingSenderId: "517379996819",
        projectId: "books-fc2b5",
        storageBucket: "books-fc2b5.appspot.com",
      ),
    );
    print("✅ Firebase initialized successfully!");
  } catch (e) {
    print("❌ Firebase initialization error: $e");
  }

  await AppTheme.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.mode,
      builder: (_, themeMode, __) {
        return MaterialApp(
          title: 'ReadAura Book Manager',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// Wrapper widget that handles authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges(),
      builder: (context, snapshot) {
        // Show splash while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(shouldNavigate: false);
        }

        // If user is logged in, check if admin and navigate accordingly
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<bool>(
            future: AuthService.isAdmin(),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen(shouldNavigate: false);
              }

              // If admin, show admin screen; otherwise show user home
              if (adminSnapshot.data == true) {
                return const AdminHomeScreen();
              } else {
                return const MainAppScreen();
              }
            },
          );
        }

        // User is not logged in, show login/register screen
        return const ClickScreen();
      },
    );
  }
}
