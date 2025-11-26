import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

/// Book service for handling book operations
class BookService {
  /// Get all books as a stream
  static Stream<QuerySnapshot> getBooksStream() {
    try {
      return FirestoreService.books
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      throw FirestoreService.getErrorMessage(e);
    }
  }

  /// Get all books as a future
  static Future<List<QueryDocumentSnapshot>> getBooks() async {
    try {
      final snapshot = await FirestoreService.books
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs;
    } catch (e) {
      throw FirestoreService.getErrorMessage(e);
    }
  }

  /// Get a single book by ID
  static Future<DocumentSnapshot> getBookById(String bookId) async {
    try {
      return await FirestoreService.books.doc(bookId).get();
    } catch (e) {
      throw FirestoreService.getErrorMessage(e);
    }
  }

  /// Search books by title, author, or category
  static Future<List<QueryDocumentSnapshot>> searchBooks(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      final snapshot = await FirestoreService.books.get();
      final queryLower = query.toLowerCase();

      return snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final title = data['title']?.toString().toLowerCase() ?? '';
        final author = data['author']?.toString().toLowerCase() ?? '';
        final category = data['category']?.toString().toLowerCase() ?? '';
        final description = data['description']?.toString().toLowerCase() ?? '';

        return title.contains(queryLower) ||
            author.contains(queryLower) ||
            category.contains(queryLower) ||
            description.contains(queryLower);
      }).toList();
    } catch (e) {
      throw FirestoreService.getErrorMessage(e);
    }
  }

  /// Add a new book (admin only)
  static Future<void> addBook(Map<String, dynamic> bookData) async {
    try {
      await FirestoreService.books.add({
        ...bookData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreService.getErrorMessage(e);
    }
  }

  /// Update a book (admin only)
  static Future<void> updateBook(String bookId, Map<String, dynamic> bookData) async {
    try {
      await FirestoreService.books.doc(bookId).update({
        ...bookData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreService.getErrorMessage(e);
    }
  }

  /// Delete a book (admin only)
  static Future<void> deleteBook(String bookId) async {
    try {
      await FirestoreService.books.doc(bookId).delete();
    } catch (e) {
      throw FirestoreService.getErrorMessage(e);
    }
  }
}

