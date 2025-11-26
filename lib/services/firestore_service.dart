import 'package:cloud_firestore/cloud_firestore.dart';

/// Base Firestore service with common operations
class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get Firestore instance
  static FirebaseFirestore get instance => _firestore;

  /// Get books collection reference
  static CollectionReference get books => _firestore.collection('books');

  /// Get customer collection reference
  static CollectionReference get customer => _firestore.collection('customer');

  /// Generic error handler
  static String _handleError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Permission denied. Please check your access.';
        case 'unavailable':
          return 'Service temporarily unavailable. Please try again.';
        default:
          return 'Error: ${error.message ?? error.toString()}';
      }
    }
    return 'An unexpected error occurred: ${error.toString()}';
  }

  /// Helper to show error messages (to be used with context in UI)
  static String getErrorMessage(dynamic error) => _handleError(error);
}

