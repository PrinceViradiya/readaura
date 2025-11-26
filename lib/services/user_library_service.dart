import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

/// Helper methods for user-specific bookmarks and downloads.
class UserLibraryService {
  UserLibraryService._();

  static CollectionReference<Map<String, dynamic>> _bookmarkRef(String userId) {
    return FirestoreService.customer.doc(userId).collection('bookmarks');
  }

  static CollectionReference<Map<String, dynamic>> _downloadRef(String userId) {
    return FirestoreService.customer.doc(userId).collection('downloads');
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> bookmarksStream(String userId) {
    return _bookmarkRef(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> downloadsStream(String userId) {
    return _downloadRef(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  static Future<bool> isBookmarked(String userId, String bookId) async {
    final doc = await _bookmarkRef(userId).doc(bookId).get();
    return doc.exists;
  }

  static Future<bool> isDownloaded(String userId, String bookId) async {
    final doc = await _downloadRef(userId).doc(bookId).get();
    return doc.exists;
  }

  static Future<void> saveBookmark({
    required String userId,
    required String bookId,
    required Map<String, dynamic> bookData,
  }) async {
    await _bookmarkRef(userId).doc(bookId).set({
      'bookId': bookId,
      'title': bookData['title'] ?? '',
      'author': bookData['author'] ?? '',
      'coverUrl': bookData['coverUrl'] ?? '',
      'category': bookData['category'] ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> removeBookmark({
    required String userId,
    required String bookId,
  }) async {
    await _bookmarkRef(userId).doc(bookId).delete();
  }

  static Future<void> saveDownload({
    required String userId,
    required String bookId,
    required Map<String, dynamic> bookData,
    String status = 'downloaded',
    double progress = 1.0,
  }) async {
    await _downloadRef(userId).doc(bookId).set({
      'bookId': bookId,
      'title': bookData['title'] ?? '',
      'author': bookData['author'] ?? '',
      'coverUrl': bookData['coverUrl'] ?? '',
      'status': status,
      'progress': progress,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> removeDownload({
    required String userId,
    required String bookId,
  }) async {
    await _downloadRef(userId).doc(bookId).delete();
  }
}

