import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  Map<Mood, int> _moodStats = {};
  int _totalEntries = 0;
  int _currentStreak = 0;
  List<String> _allTags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void refresh() {
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final moodStats = await _databaseService.getMoodStatistics();
    final totalEntries = await _databaseService.getTotalEntriesCount();
    final currentStreak = await _databaseService.getCurrentStreak();
    final allTags = await _databaseService.getAllTags();

    setState(() {
      _moodStats = moodStats;
      _totalEntries = totalEntries;
      _currentStreak = currentStreak;
      _allTags = allTags;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text(
                        'Your Journey',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFE8E5FF), Color(0xFFF5F0FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatCards(),
                          const SizedBox(height: 24),
                          _buildMoodSection(),
                          const SizedBox(height: 24),
                          _buildTagsSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.book,
            value: '$_totalEntries',
            label: 'Total Entries',
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            value: '$_currentStreak',
            label: 'Day Streak',
            color: AppTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_emotions,
            value: '${_moodStats.values.fold(0, (a, b) => a + b)}',
            label: 'Mood Logs',
            color: AppTheme.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSection() {
    final moodCount = _moodStats.values.fold(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.mood, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Mood Distribution',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (moodCount == 0)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No mood data yet.\nStart logging your moods!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    Mood.values.map((mood) {
                      final count = _moodStats[mood] ?? 0;
                      final percentage =
                          moodCount > 0 ? (count / moodCount * 100).round() : 0;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              count > 0
                                  ? AppTheme.primaryColor.withOpacity(0.1)
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              mood.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$count',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    count > 0
                                        ? AppTheme.textPrimary
                                        : Colors.grey,
                              ),
                            ),
                            if (percentage > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '($percentage%)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.tag, color: AppTheme.secondaryColor),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Your Tags',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_allTags.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No tags yet.\nAdd tags to your entries to see them here!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _allTags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          color: AppTheme.textPrimary,
                        ),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
