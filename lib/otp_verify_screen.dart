import 'package:flutter/material.dart';
import 'reset_password_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  final String expectedOtp;
  const OtpVerifyScreen({
    super.key,
    required this.email,
    required this.expectedOtp,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _otpError;
  bool _verifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verify() async {
    setState(() {
      _otpError = null;
    });

    final input = _otpController.text.trim();
    if (input.length != 6) {
      setState(() {
        _otpError = 'Enter 6-digit OTP';
      });
      return;
    }

    setState(() {
      _verifying = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    // Accept any 6-digit OTP - no validation against expected OTP
    if (!mounted) return;
    setState(() {
      _verifying = false;
    });

    // Navigate to reset password screen to set a new password
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(email: widget.email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(isTablet ? 32 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 40 : (isLandscape ? 20 : 30)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Check your email',
                  style: TextStyle(
                    color: const Color(0xFF1E3A8A),
                    fontSize: isTablet ? 32 : (isLandscape ? 20 : 24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Text(
                  'We sent a reset link to ${widget.email}. Enter the 6-digit code mentioned in the email',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isTablet ? 14 : 13,
                  ),
                ),
                SizedBox(height: isLandscape ? 20 : 30),
                Text(
                  'OTP Code',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isTablet ? 20 : (isLandscape ? 14 : 16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _otpController,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter 6-digit code',
                    filled: true,
                    fillColor: Colors.grey[100],
                    errorText: _otpError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Color(0xFF1E3A8A), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifying ? null : _verify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      elevation: 1,
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 18 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _verifying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Verify Code'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
