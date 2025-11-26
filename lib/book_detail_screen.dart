import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'reading_screen.dart';
import 'services/user_library_service.dart';

class BookDetailScreen extends StatefulWidget {
  final String? bookId;
  final String bookTitle;
  final String author;
  final String? coverUrl;
  final String? description;

  const BookDetailScreen({
    super.key,
    this.bookId,
    required this.bookTitle,
    required this.author,
    this.coverUrl,
    this.description,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isBookmarked = false;
  bool _bookmarkLoading = false;
  bool _isDownloaded = false;
  bool _downloadLoading = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;
  
  String _resolveCoverUrl() {
    if (widget.coverUrl != null && widget.coverUrl!.isNotEmpty) {
      return widget.coverUrl!;
    }
    final title = widget.bookTitle.trim().toLowerCase();
    final Map<String, String> knownCovers = {
      'the great gatsby': 'https://upload.wikimedia.org/wikipedia/en/f/f7/TheGreatGatsby_1925jacket.jpeg',
      'to kill a mockingbird': 'https://upload.wikimedia.org/wikipedia/en/7/79/To_Kill_a_Mockingbird.JPG',
      '1984': 'https://upload.wikimedia.org/wikipedia/en/c/c3/1984first.jpg',
      'pride and prejudice': 'https://upload.wikimedia.org/wikipedia/commons/1/15/PrideAndPrejudiceTitlePage.jpg',
      'the catcher in the rye': 'https://upload.wikimedia.org/wikipedia/en/3/32/Rye_catcher.jpg',
      'the journey to the west': 'https://covers.openlibrary.org/b/olid/OL24310771M-L.jpg',
      'choral': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800',
    };
    return knownCovers[title] ?? 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800';
  }

  @override
  void initState() {
    super.initState();
    _hydrateLibraryState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _hydrateLibraryState() async {
    final user = _currentUser;
    final bookId = widget.bookId;
    if (user == null || bookId == null) return;
    try {
      final bookmarked =
          await UserLibraryService.isBookmarked(user.uid, bookId);
      final downloaded =
          await UserLibraryService.isDownloaded(user.uid, bookId);
      if (!mounted) return;
      setState(() {
        _isBookmarked = bookmarked;
        _isDownloaded = downloaded;
      });
    } catch (_) {
      // Silently ignore; UI will stay in default state.
    }
  }

  Future<void> _toggleBookmark() async {
    final user = _currentUser;
    final bookId = widget.bookId;
    if (bookId == null) {
      _showSnack('Bookmarking unavailable for this book.', isError: true);
      return;
    }
    if (user == null) {
      _showSnack('Sign in to manage bookmarks.', isError: true);
      return;
    }
    if (_bookmarkLoading) return;
    setState(() => _bookmarkLoading = true);
    try {
      if (_isBookmarked) {
        await UserLibraryService.removeBookmark(
          userId: user.uid,
          bookId: bookId,
        );
      } else {
        await UserLibraryService.saveBookmark(
          userId: user.uid,
          bookId: bookId,
          bookData: {
            'title': widget.bookTitle,
            'author': widget.author,
            'coverUrl': widget.coverUrl ?? _resolveCoverUrl(),
          },
        );
      }
      if (!mounted) return;
      setState(() => _isBookmarked = !_isBookmarked);
      _showSnack(_isBookmarked
          ? 'Added to bookmarks'
          : 'Removed from bookmarks');
    } catch (e) {
      _showSnack('Failed to update bookmark: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _bookmarkLoading = false);
      }
    }
  }

  Future<void> _handleDownload() async {
    final user = _currentUser;
    final bookId = widget.bookId;
    if (bookId == null) {
      _showSnack('Downloading unavailable for this book.', isError: true);
      return;
    }
    if (user == null) {
      _showSnack('Sign in to download books.', isError: true);
      return;
    }
    if (_downloadLoading || _isDownloaded) return;
    setState(() => _downloadLoading = true);
    try {
      await UserLibraryService.saveDownload(
        userId: user.uid,
        bookId: bookId,
        bookData: {
          'title': widget.bookTitle,
          'author': widget.author,
          'coverUrl': widget.coverUrl ?? _resolveCoverUrl(),
        },
        progress: 1.0,
      );
      if (!mounted) return;
      setState(() => _isDownloaded = true);
      _showSnack('Book saved for offline reading');
    } catch (e) {
      _showSnack('Failed to download: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _downloadLoading = false);
      }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final canBookmark = widget.bookId != null;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Top bar with back and bookmark
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back,
                          color: theme.iconTheme.color),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: canBookmark ? _toggleBookmark : null,
                      tooltip: canBookmark
                          ? (_isBookmarked
                              ? 'Remove bookmark'
                              : 'Add to bookmarks')
                          : 'Bookmark unavailable',
                      icon: _bookmarkLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline,
                              color: theme.iconTheme.color,
                            ),
                    ),
                  ],
                ),
              ),

              // Book cover and details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      // Book cover
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 200,
                          height: 280,
                          child: Image.network(
                            _resolveCoverUrl(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Book title
                      Text(
                        widget.bookTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10),

                      // Author
                      Text(
                        'by ${widget.author}',
                        style: TextStyle(
                          fontSize: 16, 
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 30),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReadingScreen(
                                      bookTitle: widget.bookTitle,
                                      author: widget.author,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Read',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isDownloaded ? null : _handleDownload,
                              icon: _downloadLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      _isDownloaded
                                          ? Icons.check_circle
                                          : Icons.download,
                                    ),
                              label: Text(
                                _isDownloaded ? 'Downloaded' : 'Download',
                                style: const TextStyle(fontSize: 16),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Book description
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            widget.description ?? 
                            'No description available for this book.',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.85),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
