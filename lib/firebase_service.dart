import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Reference to books collection
  static CollectionReference get books => _firestore.collection('books');

  // Add a new book - SIMPLE VERSION
  static Future<void> addBook(Map<String, dynamic> bookData) async {
    try {
      print("📖 Adding book: ${bookData['title']}");
      
      // Add with timestamp
      await books.add({
        ...bookData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      print("✅ Book added successfully!");
    } catch (e) {
      print("❌ Error adding book: $e");
      throw "Failed to add book. Please check your connection.";
    }
  }

  // Get all books stream
  static Stream<QuerySnapshot> getBooksStream() {
    return books
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Delete a book
  static Future<void> deleteBook(String bookId) async {
    try {
      await books.doc(bookId).delete();
      print("✅ Book deleted!");
    } catch (e) {
      print("❌ Error deleting book: $e");
      throw "Failed to delete book.";
    }
  }

  // Search books (simple version)
  static Future<List<QueryDocumentSnapshot>> searchBooks(String query) async {
    try {
      final snapshot = await books.get();
      return snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final title = data['title']?.toString().toLowerCase() ?? '';
        final author = data['author']?.toString().toLowerCase() ?? '';
        return title.contains(query.toLowerCase()) || 
               author.contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw "Search failed: $e";
    }
  }
}