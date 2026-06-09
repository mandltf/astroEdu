import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'home_screen.dart';
import '../game/catch_star_game.dart';
import '../ai/astrobot_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey<ProfileScreenState>();
  
  // Lazy loading: widget dibuat saat pertama kali dibuka
  late final List<Widget?> _screens = [
    const HomeScreen(),
    null, // Game akan dibuat saat tab Game dipilih
    const AstroBotScreen(),
    ProfileScreen(key: _profileKey),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    if (_currentIndex == 3) {
      // Need a slight delay to allow the key to attach before calling loadProfile
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _profileKey.currentState?.loadProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens.asMap().entries.map((entry) {
          final index = entry.key;
          final widget = entry.value;
          
          // Jika widget null dan ini tab Game (index 1), buat widget baru
          if (widget == null && index == 1) {
            return const SizedBox(); // Placeholder sementara
          }
          return widget ?? const SizedBox();
        }).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          border: Border(top: BorderSide(color: AppTheme.cardBorder, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) {
            // Jika memilih tab Game dan widget masih null, buat baru
            if (i == 1 && _screens[1] == null) {
              setState(() {
                _screens[1] = const CatchStarGame();
              });
            }
            if (i == 3) {
              _profileKey.currentState?.loadProfile();
            }
            setState(() {
              _currentIndex = i;
            });
          },
          indicatorColor: AppTheme.auroraBlue.withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Color(0xFF6B7280)),
              selectedIcon: Icon(Icons.home, color: AppTheme.auroraBlue),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.sports_esports_outlined, color: Color(0xFF6B7280)),
              selectedIcon: Icon(Icons.sports_esports, color: AppTheme.auroraBlue),
              label: 'Game',
            ),
            NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined, color: Color(0xFF6B7280)),
              selectedIcon: Icon(Icons.smart_toy, color: AppTheme.auroraBlue),
              label: 'AstroBot',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: Color(0xFF6B7280)),
              selectedIcon: Icon(Icons.person, color: AppTheme.auroraBlue),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}