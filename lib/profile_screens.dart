import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feedback_screen.dart';
import 'login_screen.dart';
import 'app_theme.dart';
import 'library_screens.dart';
import 'about_us_page.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  String _userName = 'User';
  String _userEmail = '';
  VoidCallback? _themeListener;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 768),
            child: Container(
              margin: EdgeInsets.all(isMobile ? 0 : 20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(isMobile ? 0 : 20),
              ),
              child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          child: const Icon(
                            Icons.person,
                            size: 56,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userEmail,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit Profile'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildCardSection([
                      _buildMenuItem(
                        Icons.bookmark,
                        'Bookmarks',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LibraryScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        Icons.download,
                        'Downloads',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LibraryScreen(
                                  initialCategory: 'Download'),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                        _isDarkMode ? 'Light Mode' : 'Dark Mode',
                        isToggle: true,
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildCardSection([
                      _buildMenuItem(
                        Icons.history,
                        'Clear History',
                        onTap: _showClearHistoryDialog,
                      ),
                      _buildMenuItem(
                        Icons.info_outline,
                        'About Us',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutUsPage(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        Icons.feedback_outlined,
                        'Feedback',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeedbackScreen(),
                            ),
                          );
                        },
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildCardSection([
                      _buildMenuItem(
                        Icons.logout,
                        'Log Out',
                        onTap: _showLogoutDialog,
                      ),
                    ]),
                  ]),
                ),
              ),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _isDarkMode = AppTheme.mode.value == ThemeMode.dark;
    _themeListener = () {
      if (!mounted) return;
      setState(() {
        _isDarkMode = AppTheme.mode.value == ThemeMode.dark;
      });
    };
    AppTheme.mode.addListener(_themeListener!);
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? '';
      });

      try {
        final profile = await ProfileService.getUserProfile(user.uid);
        if (profile != null && mounted) {
          setState(() {
            _userName = profile['name'] ?? user.displayName ?? 'User';
            _userEmail = profile['email'] ?? user.email ?? '';
          });
        }
      } catch (e) {
        print('Error loading profile: $e');
        if (mounted) {
          setState(() {
            _userName = user.displayName ?? 'User';
            _userEmail = user.email ?? '';
          });
        }
      }
    }
  }

  @override
  void dispose() {
    if (_themeListener != null) {
      AppTheme.mode.removeListener(_themeListener!);
    }
    super.dispose();
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    bool isToggle = false,
    VoidCallback? onTap,
  }) {
    final row = Row(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: (_isDarkMode ? Colors.white : const Color(0xFF1E3A8A))
                .withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: _isDarkMode ? Colors.white : const Color(0xFF1E3A8A),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (isToggle)
          Switch(
            value: AppTheme.mode.value == ThemeMode.dark,
            onChanged: (value) {
              AppTheme.setDark(value);
              setState(() {
                _isDarkMode = value;
              });
            },
          )
        else
          Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
      ],
    );

    return isToggle
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: _isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: row,
          )
        : InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: row,
            ),
          );
  }

  Widget _buildCardSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: Colors.grey[200]),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: children[i],
            ),
          ],
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text(
            'Are you sure you want to clear your reading history? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History cleared successfully!'),
                    backgroundColor: Color(0xFF1E3A8A),
                  ),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    final parentContext = context;
    showDialog(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await AuthService.signOut();
                  // Navigate to login and clear back stack using parent context
                  if (parentContext.mounted) {
                    Navigator.of(parentContext).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  }
                } catch (e) {
                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final profile = await ProfileService.getUserProfile(user.uid);
        if (profile != null && mounted) {
          setState(() {
            _usernameController.text = profile['name'] ?? '';
            _emailController.text = profile['email'] ?? user.email ?? '';
            _phoneController.text = profile['phone'] ?? '';
            _addressController.text = profile['address'] ?? '';
            _isLoadingData = false;
          });
        } else {
          // If no profile exists, use auth data
          setState(() {
            _usernameController.text = user.displayName ?? '';
            _emailController.text = user.email ?? '';
            _isLoadingData = false;
          });
        }
      } catch (e) {
        print('Error loading profile: $e');
        if (mounted) {
          setState(() {
            _usernameController.text = user.displayName ?? '';
            _emailController.text = user.email ?? '';
            _isLoadingData = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(isMobile ? 0 : 20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(isMobile ? 0 : 20),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          color: theme.iconTheme.color,
                        ),
                      ),
                      const Spacer(),
                      // Dark mode toggle handled on Profile main screen
                    ],
                  ),
                ),

                // Profile picture section
                Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _changeProfilePicture,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E3A8A),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _changeProfilePicture,
                      child: const Text(
                        'Change Picture',
                        style: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Form fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      if (_isLoadingData)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        _buildTextField('Name', _usernameController),
                        const SizedBox(height: 20),
                        _buildTextField('Email', _emailController, enabled: false),
                        const SizedBox(height: 20),
                        _buildTextField('Phone', _phoneController),
                        const SizedBox(height: 20),
                        _buildTextField('Address', _addressController, maxLines: 2),
                      ],
                      const SizedBox(height: 40),

                      // Update button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Update Profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool enabled = true,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          enabled: enabled,
          maxLines: maxLines,
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[600]!
                    : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[600]!
                    : Colors.grey[300]!,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Change Profile Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(Icons.camera_alt, 'Camera', () {
                    Navigator.pop(context);
                    _showSnackBar('Camera feature coming soon!');
                  }),
                  _buildImageOption(Icons.photo_library, 'Gallery', () {
                    Navigator.pop(context);
                    _showSnackBar('Gallery feature coming soon!');
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  void _updateProfile() async {
    if (_usernameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your name');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar('No user logged in');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ProfileService.updateUserProfile(
        userId: user.uid,
        name: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (mounted) {
        _showSnackBar('Profile updated successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error updating profile: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }
}
