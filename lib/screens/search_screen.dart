import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'journal_entry_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  List<JournalEntry> _results = [];
  List<JournalEntry> _recentEntries = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRecentEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentEntries() async {
    final entries = await _databaseService.getAllEntries();
    setState(() {
      _recentEntries = entries.take(5).toList();
    });
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await _databaseService.searchEntries(query);
    setState(() {
      _results = results;
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
    ).then((_) {
      _search(_searchController.text);
      _loadRecentEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Search'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _search,
                  decoration: InputDecoration(
                    hintText: 'Search entries, tags, content...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _search('');
                              },
                            )
                            : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isSearching)
            _results.isEmpty
                ? const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final entry = _results[index];
                    return _SearchResultTile(
                      entry: entry,
                      query: _searchController.text,
                      onTap: () => _navigateToEntry(entry),
                    );
                  }, childCount: _results.length),
                )
          else ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Recent Entries',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
            if (_recentEntries.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No entries yet.\nStart writing your first journal entry!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final entry = _recentEntries[index];
                  return _SearchResultTile(
                    entry: entry,
                    query: '',
                    onTap: () => _navigateToEntry(entry),
                  );
                }, childCount: _recentEntries.length),
              ),
          ],
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final JournalEntry entry;
  final String query;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.entry,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child:
                entry.mood != null
                    ? Text(
                      entry.mood!.emoji,
                      style: const TextStyle(fontSize: 24),
                    )
                    : const Icon(Icons.book, color: AppTheme.primaryColor),
          ),
        ),
        title: Text(
          entry.title.isEmpty ? 'Untitled' : entry.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              entry.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children:
                    entry.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
        trailing:
            entry.isFavorite
                ? const Icon(Icons.star, color: Colors.amber)
                : null,
      ),
    );
  }
}
