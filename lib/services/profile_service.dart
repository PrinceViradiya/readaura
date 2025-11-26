import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

/// Profile service for handling user profile operations
class ProfileService {
  /// Get user profile from Firestore
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await FirestoreService.customer.doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw FirestoreService.getErrorMessage(e);
    }
  }

  /// Get user profile as a stream
  static Stream<DocumentSnapshot> getUserProfileStream(String userId) {
    try {
      return FirestoreService.customer.doc(userId).snapshots();
    } catch (e) {
      throw FirestoreService.getErrorMessage(e);
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }
      if (phone != null && phone.trim().isNotEmpty) {
        updateData['phone'] = phone.trim();
      }
      if (address != null && address.trim().isNotEmpty) {
        updateData['address'] = address.trim();
      }

      await FirestoreService.customer.doc(userId).update(updateData);
    } catch (e) {
      throw FirestoreService.getErrorMessage(e);
    }
  }

  /// Update user name only
  static Future<void> updateUserName(String userId, String name) async {
    try {
      await FirestoreService.customer.doc(userId).update({
        'name': name.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreService.getErrorMessage(e);
    }
  }

  /// Get current user's profile
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      return await getUserProfile(user.uid);
    } catch (e) {
      throw FirestoreService.getErrorMessage(e);
    }
  }
}

