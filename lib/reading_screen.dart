import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'app_theme.dart';
import 'library_screens.dart';

class ReadingScreen extends StatefulWidget {
  final String bookTitle;
  final String author;

  const ReadingScreen({
    super.key,
    required this.bookTitle,
    required this.author,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  bool _isDarkMode = false;
  double _fontSize = 16.0;
  int _currentPage = 0;
  int _totalPages = 0;
  String _selectedLanguage = 'English';
  bool _showTranslated = false;
  bool _showLanguageOptions = false;
  final GoogleTranslator _translator = GoogleTranslator();
  final PageController _pageController = PageController();
  final int _maxCharsPerPage = 1200;

  List<String> _originalPages = [];
  List<String>? _translatedPages;
  VoidCallback? _themeListener;

  String get _originalContent =>
      'It was a dark and stormy night when our protagonist first discovered the ancient tome hidden beneath the floorboards of the old library. The leather-bound book seemed to pulse with an otherworldly energy, its pages filled with text that shifted and shimmered as if written by the wind itself. Lantern light trembled across the desk while thunder rolled like a distant drum. In that moment, he felt history breathing'
      'The journey that lay ahead would test every fiber of his being, challenging not only his strength but the convictions he held about what is true, what is possible, and what it means to be courageous. He turned the first page with reverence. The script spoke of a Cartographer of Ages who mapped not only lands and seas, but memory, time, and the secret places where choices are born. Whoever completed the map would be able to heal the world—or unmake it'
      'The story begins in a quiet valley village, veiled by morning fog and the unhurried rhythm of small lives. In the bakery, bread rose like soft mountains; in the fields, dew jeweled the wheat. Nothing extraordinary ever seemed to happen there, and perhaps that was the village’s greatest magic: the faithful hum of ordinary days. Yet even in quiet places, destiny keeps a careful watch.'
      'Our hero—Eshan, a young scholar with a talent for hearing what others miss—had always felt that there was more to the world than markets and seasons. He listened to the hush between church bells, the silence that followed a sparrow’s wingbeat, the way river water changed its voice when storms approached. In those subtleties, meaning gathered like rain.'
      'On the morning everything changed, Eshan discovered a fragment of the Map of Ages pressed into the lining of the old tome. It was inked in a metallic blue that deepened and brightened as it caught the sun, and around its edges danced notes in a language that felt familiar the way a memory does. The fragment showed no borders and no names—only pathways of light that branched like roots and constellations.'
      'The ancient text spoke of six lost fragments scattered across the known world, each guarded by a trial that could not be passed with strength alone. Wisdom, empathy, patience, and wonder would be demanded in equal measure. If brought together, the fragments would reveal the Cartographer’s final journey: a road that crossed oceans, climbed the air itself, and descended into the heart’s deepest chamber.'
      'Eshan’s first steps took him beyond the valley, where the hills rolled like sleeping giants and the sky opened wide with promise. He met travelers who traded stories as if they were precious coins. He learned how to hear the difference between a guarded tale and a gift freely given. With each conversation, the map fragment in his satchel glowed faintly, as if language itself was a lantern.'
      'By the time he reached the cliff city of Vaelor, where homes were carved straight into the stone and wind-songs were taught to children, Eshan had begun to understand: the fragments were drawn to meaning. In the library of winds, he encountered Mira—an archivist whose laughter rang like bright glass. She showed him a scroll that could only be read by holding it up to the sky at dusk. Together, they watched as the fading sun inked letters onto the page. The scroll revealed the second fragment’s resting place: beneath a lake that did not mirror.'
      'They traveled together, learning the art of quiet companionship. At the lake with no reflection, they faced their first trial. The waters were perfectly still, yet when Eshan peered over the surface, he saw not his face but the choices he’d avoided. He saw friendships left to wither, promises kept too late, and truths gently moved aside to keep the peace. He understood then why the lake gave no mirror: it showed not the body but the soul. He spoke his regrets aloud, not as penance, but as a promise to live differently. The waters stirred, and the second fragment rose like a new moon from the depths.';

  @override
  void initState() {
    super.initState();
    _originalPages = _paginateContent(_originalContent, _maxCharsPerPage);
    _totalPages = _originalPages.length;
    _isDarkMode = AppTheme.mode.value == ThemeMode.dark;
    _themeListener = () {
      if (!mounted) return;
      setState(() {
        _isDarkMode = AppTheme.mode.value == ThemeMode.dark;
      });
    };
    AppTheme.mode.addListener(_themeListener!);
  }

  @override
  void dispose() {
    if (_themeListener != null) {
      AppTheme.mode.removeListener(_themeListener!);
    }
    _pageController.dispose();
    super.dispose();
  }

  List<String> _paginateContent(String content, int maxChars) {
    final text = content.replaceAll('\r\n', '\n');
    if (text.isEmpty || maxChars <= 0) return [];
    final List<String> pages = [];
    int cursor = 0;
    while (cursor < text.length) {
      int end = (cursor + maxChars < text.length) ? cursor + maxChars : text.length;
      if (end < text.length) {
        int backtrack = end;
        while (backtrack > cursor && !RegExp(r"\s").hasMatch(text[backtrack - 1])) {
          backtrack--;
        }
        if (backtrack > cursor) {
          end = backtrack;
        }
      }
      final page = text.substring(cursor, end).trim();
      if (page.isNotEmpty) pages.add(page);
      cursor = end;
      while (cursor < text.length && RegExp(r"\s").hasMatch(text[cursor])) {
        cursor++;
      }
    }
    return pages;
  }

  Future<void> _translateAndCache() async {
    setState(() {
      _translatedPages = null;
    });

    final Map<String, String> langCodes = {
      'English': 'en',
      'Hindi': 'hi',
      'Gujarati': 'gu',
      'Tamil': 'ta',
    };

    final code = langCodes[_selectedLanguage] ?? 'en';
    try {
      final result = await _translator.translate(_originalContent, to: code);
      final pages = _paginateContent(result.text, _maxCharsPerPage);
      setState(() {
        _translatedPages = pages;
        _totalPages = pages.length;
        if (_currentPage >= _totalPages) {
          _currentPage = _totalPages > 0 ? _totalPages - 1 : 0;
        }
      });
    } catch (_) {
      setState(() {
        _translatedPages = [
          'Translation failed. Please try again.'
        ];
        _totalPages = 1;
        _currentPage = 0;
      });
    }
  }

  void _toggleDarkMode() {
    AppTheme.setDark(!_isDarkMode);
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize = (_fontSize + 2).clamp(12.0, 24.0);
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _fontSize = (_fontSize - 2).clamp(12.0, 24.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.iconTheme.color,
                    ),
                  ),
                  if (_showLanguageOptions) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2C2C)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLanguage,
                          icon: Icon(
                            Icons.language,
                            color: theme.iconTheme.color?.withOpacity(0.7),
                            size: 18,
                          ),
                          dropdownColor: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                          items: const [
                            DropdownMenuItem(
                              value: 'English',
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: 'Hindi',
                              child: Text('Hindi'),
                            ),
                            DropdownMenuItem(
                              value: 'Gujarati',
                              child: Text('Gujarati'),
                            ),
                            DropdownMenuItem(
                              value: 'Tamil',
                              child: Text('Tamil'),
                            ),
                          ],
                          onChanged: (val) async {
                            if (val == null) return;
                            setState(() {
                              _selectedLanguage = val;
                              _translatedPages = null;
                            });
                            if (_showTranslated) {
                              await _translateAndCache();
                            }
                          },
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    onPressed: _toggleDarkMode,
                    icon: Icon(
                      _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: theme.iconTheme.color,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LibraryScreen(
                            initialCategory: 'Bookmark',
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.bookmark_border,
                      color: theme.iconTheme.color,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) {
                    setState(() {
                      _currentPage = i;
                    });
                  },
                  itemCount: _showTranslated
                      ? (_translatedPages?.length ?? 1)
                      : _originalPages.length,
                  itemBuilder: (context, index) {
                    final text = _showTranslated
                        ? (_translatedPages == null
                            ? 'Translating...'
                            : _translatedPages![index])
                        : _originalPages[index];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chapter 1: The Beginning',
                                  style: TextStyle(
                                    fontSize: _fontSize + 4,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textTheme.titleLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: _fontSize,
                                    color:
                                        theme.textTheme.bodyMedium?.color ??
                                            Colors.black87,
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            /// FIXED — overflow removed by adding SINGLECHILD SCROLL VIEW
            SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _decreaseFontSize,
                          icon: Icon(
                            Icons.remove,
                            color: theme.iconTheme.color,
                          ),
                        ),
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: _fontSize,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        IconButton(
                          onPressed: _increaseFontSize,
                          icon: Icon(
                            Icons.add,
                            color: theme.iconTheme.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (_showTranslated && _translatedPages != null) {
                              setState(() {
                                _showTranslated = false;
                                _showLanguageOptions = false;
                                _totalPages = _originalPages.length;
                              });
                            } else {
                              setState(() {
                                _showTranslated = true;
                                _showLanguageOptions = true;
                              });
                              await _translateAndCache();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            minimumSize: const Size(0, 0),
                          ),
                          icon: const Icon(Icons.translate, size: 18),
                          label: Text(
                            _showTranslated ? 'Show Original' : 'Translate',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Previous page',
                          onPressed: _currentPage > 0
                              ? () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                          icon: Icon(
                            Icons.chevron_left,
                            color: theme.iconTheme.color,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Next page',
                          onPressed: (_currentPage + 1) < _totalPages
                              ? () {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              : null,
                          icon: Icon(
                            Icons.chevron_right,
                            color: theme.iconTheme.color,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Page ${_totalPages == 0 ? 0 : _currentPage + 1} of $_totalPages',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: _totalPages == 0
                          ? 0
                          : (_currentPage + 1) / _totalPages,
                      backgroundColor:
                          _isDarkMode ? Colors.grey[700] : Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isDarkMode
                            ? Colors.blue[400]!
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
