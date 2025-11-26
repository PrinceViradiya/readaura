import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Authentication service for handling login, logout, and session management
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Get auth state changes stream
  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Reload user to get latest email verification status
      await userCredential.user?.reload();
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  /// Sign up with email and password
  static Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;
      if (user == null) {
        throw 'User registration failed.';
      }

      // Send email verification
      await user.sendEmailVerification();

      // Create customer document in Firestore
      await _firestore.collection('customer').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': user.emailVerified,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out: ${e.toString()}';
    }
  }

  /// Check if user is admin (via custom claims or email whitelist)
  static Future<bool> isAdmin() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      // Check custom claims first
      await user.reload();
      final idTokenResult = await user.getIdTokenResult();
      if (idTokenResult.claims?['admin'] == true) {
        return true;
      }

      // Fallback: Check email whitelist (temporary solution)
      // TODO: Replace with proper admin management
      const adminEmails = [
        'pshah627@gmail.com',
        'yuvrajdhadhal777@gmail.com',
      ]; // Add more admin emails here
      return adminEmails.contains(user.email?.toLowerCase());
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Failed to send password reset email: ${e.toString()}';
    }
  }

  /// Resend verification email
  static Future<void> resendVerificationEmail() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw 'No user is currently signed in.';
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Failed to resend verification email: ${e.toString()}';
    }
  }

  /// Handle Firebase Auth errors
  static String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        return 'Invalid credentials. Please check your email and password.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'weak-password':
        return 'The password is too weak. Must be at least 6 characters.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'Authentication error: ${e.message ?? e.code}';
    }
  }
}

