import 'package:flutter/material.dart';
import 'book_detail_screen.dart';
import 'main_app_screen.dart';

class ContinueReadingScreen extends StatelessWidget {
  const ContinueReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock data for continue reading books
    final books = [
      {
        'title': 'The Journey to the West',
        'author': 'Wu Cheng\'en',
        'coverUrl': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400',
        'progress': 0.6,
        'currentPage': 120,
        'totalPages': 200,
      },
      {
        'title': 'Choral',
        'author': 'Unknown',
        'coverUrl': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400',
        'progress': 0.3,
        'currentPage': 45,
        'totalPages': 150,
      },
      {
        'title': 'College',
        'author': 'Educational',
        'coverUrl': 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400',
        'progress': 0.8,
        'currentPage': 160,
        'totalPages': 200,
      },
      {
        'title': 'Fiction Novel',
        'author': 'Author Name',
        'coverUrl': 'https://images.unsplash.com/photo-1526318472351-c75fcf070305?w=400',
        'progress': 0.2,
        'currentPage': 30,
        'totalPages': 150,
      },
      {
        'title': 'History Book',
        'author': 'Historian',
        'coverUrl': 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=400',
        'progress': 0.9,
        'currentPage': 180,
        'totalPages': 200,
      },
      {
        'title': 'The Great Gatsby',
        'author': 'F. Scott Fitzgerald',
        'coverUrl': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400',
        'progress': 0.4,
        'currentPage': 80,
        'totalPages': 200,
      },
      {
        'title': 'To Kill a Mockingbird',
        'author': 'Harper Lee',
        'coverUrl': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400',
        'progress': 0.7,
        'currentPage': 140,
        'totalPages': 200,
      },
      {
        'title': '1984',
        'author': 'George Orwell',
        'coverUrl': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=400',
        'progress': 0.5,
        'currentPage': 100,
        'totalPages': 200,
      },
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          margin:
              EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 0 : 20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width < 600 ? 0 : 20),
          ),
          child: Padding(
            padding: EdgeInsets.all(
                MediaQuery.of(context).size.width < 600 ? 16 : 20),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    const Text(
                      'Continue Reading',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.search,
                      color: theme.iconTheme.color?.withOpacity(0.7),
                      size: 24,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Books list
                Expanded(
                  child: ListView.separated(
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final progress = book['progress'] as double;
                      final currentPage = book['currentPage'] as int;
                      final totalPages = book['totalPages'] as int;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailScreen(
                                bookTitle: book['title'] as String,
                                author: book['author'] as String,
                                coverUrl: book['coverUrl'] as String?,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 50,
                                  height: 70,
                                  child: Image.network(
                                    (book['coverUrl'] as String?) ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(color: Colors.red),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      book['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'by ${book['author'] as String}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Page $currentPage of $totalPages',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home tab index
        onTap: (index) {
          if (index != 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainAppScreen(initialIndex: index),
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E3A8A), // Blue background
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
