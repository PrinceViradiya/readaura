import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class ClickScreen extends StatelessWidget {
  const ClickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          color: Colors.white,
          child: Column(
            children: [
              // Top section with "home" text
              Padding(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: Row(
                  children: [
                    Text(
                      '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Main content area
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 24,
                    vertical: isLandscape ? 10 : 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo section
                      Container(
                        padding: EdgeInsets.all(isTablet ? 32 : 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // Logo with book icon and laurel wreaths
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Left laurel wreath
                                Icon(Icons.eco,
                                    color: Colors.black,
                                    size: isTablet
                                        ? 40
                                        : (isLandscape ? 25 : 30)),
                                SizedBox(width: isTablet ? 15 : 10),
                                // Book icon
                                Icon(
                                  Icons.menu_book,
                                  color: Colors.black,
                                  size: isTablet ? 50 : (isLandscape ? 35 : 40),
                                ),
                                SizedBox(width: isTablet ? 15 : 10),
                                // Right laurel wreath
                                Icon(Icons.eco,
                                    color: Colors.black,
                                    size: isTablet
                                        ? 40
                                        : (isLandscape ? 25 : 30)),
                              ],
                            ),
                            SizedBox(
                                height:
                                    isTablet ? 20 : (isLandscape ? 10 : 15)),
                            // READAURA text
                            Text(
                              'READAURA',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    isTablet ? 36 : (isLandscape ? 24 : 28),
                                fontWeight: FontWeight.bold,
                                letterSpacing: isTablet ? 3 : 2,
                              ),
                            ),
                            SizedBox(height: isTablet ? 12 : 8),
                            // Tagline
                            Text(
                              "'A MODERN DIGITAL LIBRARY'",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    isTablet ? 16 : (isLandscape ? 10 : 12),
                                fontWeight: FontWeight.w500,
                                letterSpacing: isTablet ? 2 : 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isLandscape ? 20 : (isTablet ? 50 : 40)),

                      // Welcome message
                      Text(
                        'Welcome to READAURA',
                        style: TextStyle(
                          color: const Color(0xFF1E3A8A), // Dark blue color
                          fontSize: isTablet ? 32 : (isLandscape ? 20 : 24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: isLandscape ? 10 : (isTablet ? 25 : 20)),

                      // Description text
                      Text(
                        'Explore all the existing Book based on\nyour interest',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: isTablet ? 20 : (isLandscape ? 14 : 16),
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: isLandscape ? 25 : (isTablet ? 60 : 50)),

                      // Login and Register buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF1E3A8A), // Dark blue
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical:
                                      isTablet ? 20 : (isLandscape ? 12 : 15),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(isTablet ? 12 : 8),
                                ),
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize:
                                      isTablet ? 20 : (isLandscape ? 14 : 16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: isTablet ? 20 : 15),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF1E3A8A), // Dark blue
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical:
                                      isTablet ? 20 : (isLandscape ? 12 : 15),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(isTablet ? 12 : 8),
                                ),
                              ),
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  fontSize:
                                      isTablet ? 20 : (isLandscape ? 14 : 16),
                                  fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }
}
