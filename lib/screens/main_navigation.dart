import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'statistics_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final GlobalKey<_FavoritesScreenWrapperState> _favoritesKey = GlobalKey();
  final GlobalKey<_StatisticsScreenWrapperState> _statisticsKey = GlobalKey();

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      return;
    }
    setState(() {
      _currentIndex = index;
    });

    if (index == 2) {
      _favoritesKey.currentState?.refresh();
    } else if (index == 3) {
      _statisticsKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          const SearchScreen(),
          _FavoritesScreenWrapper(key: _favoritesKey),
          _StatisticsScreenWrapper(key: _statisticsKey),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondary,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month),
                label: 'Calendar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_outline),
                activeIcon: Icon(Icons.star),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insights_outlined),
                activeIcon: Icon(Icons.insights),
                label: 'Insights',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesScreenWrapper extends StatefulWidget {
  const _FavoritesScreenWrapper({super.key});

  @override
  State<_FavoritesScreenWrapper> createState() =>
      _FavoritesScreenWrapperState();
}

class _FavoritesScreenWrapperState extends State<_FavoritesScreenWrapper> {
  final GlobalKey<FavoritesScreenState> _key = GlobalKey();

  void refresh() {
    _key.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return FavoritesScreen(key: _key);
  }
}

class _StatisticsScreenWrapper extends StatefulWidget {
  const _StatisticsScreenWrapper({super.key});

  @override
  State<_StatisticsScreenWrapper> createState() =>
      _StatisticsScreenWrapperState();
}

class _StatisticsScreenWrapperState extends State<_StatisticsScreenWrapper> {
  final GlobalKey<StatisticsScreenState> _key = GlobalKey();

  void refresh() {
    _key.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return StatisticsScreen(key: _key);
  }
}
