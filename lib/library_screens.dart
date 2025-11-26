import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'book_detail_screen.dart';
import 'main_app_screen.dart';
import 'search_screens.dart';
import 'services/user_library_service.dart';

class LibraryScreen extends StatefulWidget {
  final String? initialCategory;
  const LibraryScreen({super.key, this.initialCategory});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Bookmark';

  final List<String> _categories = ['Bookmark', 'Download'];

  // Recent search functionality
  List<String> _recentSearches = [];
  bool _showRecentSearches = false;

  StreamSubscription<User?>? _authSubscription;
  User? _currentUser;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _bookmarkStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _downloadStream;

  @override
  void dispose() {
    _authSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      // Add to recent searches if not already present
      if (!_recentSearches.contains(query.trim())) {
        setState(() {
          _recentSearches.insert(0, query.trim());
          // Keep only last 10 searches
          if (_recentSearches.length > 10) {
            _recentSearches = _recentSearches.take(10).toList();
          }
        });
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(query: query.trim()),
        ),
      );
    }
  }

  void _deleteRecentSearch(String searchTerm) {
    setState(() {
      _recentSearches.remove(searchTerm);
    });
  }

  void _clearAllRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    // Set initial category if provided
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      _bookmarkStream = UserLibraryService.bookmarksStream(_currentUser!.uid);
      _downloadStream = UserLibraryService.downloadsStream(_currentUser!.uid);
    }
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
        if (user != null) {
          _bookmarkStream = UserLibraryService.bookmarksStream(user.uid);
          _downloadStream = UserLibraryService.downloadsStream(user.uid);
        } else {
          _bookmarkStream = null;
          _downloadStream = null;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (ctx) =>
                                const MainAppScreen(initialIndex: 0),
                          ),
                          (route) => false,
                        );
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    const Text(
                      'Library',
                      style: TextStyle(
                        color: null,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showRecentSearches = !_showRecentSearches;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.iconTheme.color?.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.search,
                          color: theme.iconTheme.color?.withOpacity(0.8),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Categories
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1E3A8A)
                                : (theme.brightness == Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.grey[100]),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1E3A8A)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.75),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Recent searches section
                if (_showRecentSearches) ...[
                  // Search input field
                  TextField(
                    controller: _searchController,
                    onSubmitted: _performSearch,
                    decoration: InputDecoration(
                      hintText: 'Search for books...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.iconTheme.color,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => _performSearch(_searchController.text),
                        icon: Icon(
                          Icons.arrow_forward,
                          color: theme.iconTheme.color,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1E3A8A),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Recent searches container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Searches',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            if (_recentSearches.isNotEmpty)
                              TextButton(
                                onPressed: _clearAllRecentSearches,
                                child: Text(
                                  'Clear All',
                                  style: TextStyle(
                                    color: Colors.red[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_recentSearches.isEmpty)
                          Text(
                            'No recent searches',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _recentSearches.map((search) {
                              return GestureDetector(
                                onTap: () => _performSearch(search),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF1E3A8A).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        search,
                                        style: const TextStyle(
                                          color: Color(0xFF1E3A8A),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () => _deleteRecentSearch(search),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.red[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Books list
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _selectedCategory == 'Bookmark'
                        ? _buildBookmarkList(theme)
                        : _buildDownloadList(theme),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkList(ThemeData theme) {
    final user = _currentUser;
    if (user == null) {
      return _buildAuthPrompt('Log in to view your bookmarks.');
    }
    final stream = _bookmarkStream;
    if (stream == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      key: const ValueKey('bookmarkStream'),
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.bookmark_border,
            message: 'No bookmarks yet',
            actionLabel: 'Browse books',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => const MainAppScreen(initialIndex: 0),
                ),
              );
            },
          );
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final bookId = data['bookId'] as String? ?? '';
            return _buildLibraryCard(
              theme: theme,
              title: data['title'] as String? ?? 'Untitled',
              author: data['author'] as String? ?? 'Unknown',
              coverUrl: data['coverUrl'] as String? ?? '',
              onTap: bookId.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailScreen(
                            bookId: bookId,
                            bookTitle: data['title'] as String? ?? 'Untitled',
                            author: data['author'] as String? ?? 'Unknown',
                            coverUrl: data['coverUrl'] as String?,
                          ),
                        ),
                      );
                    },
              trailing: IconButton(
                tooltip: 'Remove bookmark',
                onPressed: () => _handleRemoveBookmark(bookId),
                icon: const Icon(Icons.bookmark_remove, color: Colors.redAccent),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDownloadList(ThemeData theme) {
    final user = _currentUser;
    if (user == null) {
      return _buildAuthPrompt('Log in to view your downloads.');
    }
    final stream = _downloadStream;
    if (stream == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      key: const ValueKey('downloadStream'),
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.download_for_offline_outlined,
            message: 'No downloads yet',
            actionLabel: 'Download a book',
            onPressed: () => setState(() => _selectedCategory = 'Bookmark'),
          );
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final bookId = data['bookId'] as String? ?? '';
            final progress = (data['progress'] as num?)?.toDouble() ?? 1.0;
            final isComplete = progress >= 1.0;
            return _buildLibraryCard(
              theme: theme,
              title: data['title'] as String? ?? 'Untitled',
              author: data['author'] as String? ?? 'Unknown',
              coverUrl: data['coverUrl'] as String? ?? '',
              onTap: bookId.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailScreen(
                            bookId: bookId,
                            bookTitle: data['title'] as String? ?? 'Untitled',
                            author: data['author'] as String? ?? 'Unknown',
                            coverUrl: data['coverUrl'] as String?,
                          ),
                        ),
                      );
                    },
              trailing: IconButton(
                tooltip: 'Remove download',
                onPressed: () => _handleRemoveDownload(bookId),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
              progressWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.clamp(0, 1),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isComplete
                          ? Colors.green
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isComplete
                        ? 'Ready to read offline'
                        : '${(progress * 100).floor()}% downloaded',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodySmall?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLibraryCard({
    required ThemeData theme,
    required String title,
    required String author,
    required String coverUrl,
    required VoidCallback? onTap,
    required Widget trailing,
    Widget? progressWidget,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 80,
                child: coverUrl.isEmpty
                    ? Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.menu_book),
                      )
                    : Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey[300]),
                      ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color
                          ?.withOpacity(0.7),
                    ),
                  ),
                  if (progressWidget != null) progressWidget,
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildAuthPrompt(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline,
              size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54, color: theme.iconTheme.color?.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
          ),
          if (actionLabel != null && onPressed != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }

  Future<void> _handleRemoveBookmark(String bookId) async {
    final user = _currentUser;
    if (user == null || bookId.isEmpty) return;
    try {
      await UserLibraryService.removeBookmark(
        userId: user.uid,
        bookId: bookId,
      );
      _showSnack('Bookmark removed');
    } catch (e) {
      _showSnack('Failed to remove: $e', isError: true);
    }
  }

  Future<void> _handleRemoveDownload(String bookId) async {
    final user = _currentUser;
    if (user == null || bookId.isEmpty) return;
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Remove download?'),
            content: const Text(
                'This will delete the offline copy from your library.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Remove'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    try {
      await UserLibraryService.removeDownload(
        userId: user.uid,
        bookId: bookId,
      );
      _showSnack('Download removed');
    } catch (e) {
      _showSnack('Failed to remove: $e', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF1E3A8A),
      ),
    );
  }
}
