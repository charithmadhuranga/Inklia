import 'dart:io';
import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'journal_entry_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<JournalEntry> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void refresh() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    final favorites = await _databaseService.getFavoriteEntries();
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  void _navigateToEntry(JournalEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => JournalEntryScreen(
              selectedDate: entry.date,
              existingEntry: entry,
            ),
      ),
    ).then((_) => _loadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _favorites.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_border,
                        size: 64,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Favorites Yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Star your favorite journal entries to find them quickly here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              )
              : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    title: const Text('Favorites'),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final entry = _favorites[index];
                        return _FavoriteCard(
                          entry: entry,
                          onTap: () => _navigateToEntry(entry),
                        );
                      }, childCount: _favorites.length),
                    ),
                  ),
                ],
              ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const _FavoriteCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.imagePaths.isNotEmpty)
              Expanded(
                flex: 3,
                child: Image.file(
                  File(entry.imagePaths.first),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.3),
                        AppTheme.secondaryColor.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child:
                        entry.mood != null
                            ? Text(
                              entry.mood!.emoji,
                              style: const TextStyle(fontSize: 48),
                            )
                            : const Icon(
                              Icons.book,
                              size: 48,
                              color: Colors.white,
                            ),
                  ),
                ),
              ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.title.isEmpty ? 'Untitled' : entry.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
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
