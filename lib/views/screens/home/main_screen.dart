import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';
import 'home_screen.dart';
import '../game/catch_star_game.dart';
import '../ai/astrobot_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // Lazy loading: widget dibuat saat pertama kali dibuka
  final List<Widget?> _screens = [
    const HomeScreen(),
    null, // Game akan dibuat saat tab Game dipilih
    const AstroBotScreen(),
    const ProfileScreen(),
  ];

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