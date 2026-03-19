import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'viewer/home_screen.dart';
import 'viewer/directory_screen.dart';
import 'viewer/favorites_screen.dart';
import 'viewer/notifications_screen.dart';
import 'viewer/profile_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'viewer/chatbot_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  List<Widget> get _viewerScreens => [
    const HomeScreen(),
    const DirectoryScreen(),
    const FavoritesScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  List<Widget> get _adminScreens => [
    const AdminDashboardScreen(),
    const DirectoryScreen(),
    const FavoritesScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isAdmin = provider.currentUser?.role == UserRole.admin;
    final screens = isAdmin ? _adminScreens : _viewerScreens;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChatbot(context),
        backgroundColor: AppTheme.accentGold,
        elevation: 4,
        child: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryNavy),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryNavy,
          unselectedItemColor: AppTheme.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: [
            BottomNavigationBarItem(
              icon: Icon(isAdmin ? Icons.dashboard_outlined : Icons.home_outlined),
              activeIcon: Icon(isAdmin ? Icons.dashboard : Icons.home),
              label: isAdmin ? 'Dashboard' : 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Directory',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Consumer<AppProvider>(
                builder: (_, p, __) => NotificationBell(
                  count: p.unreadNotificationCount,
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
              ),
              activeIcon: const Icon(Icons.notifications),
              label: 'Alerts',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _showChatbot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatbotScreen(),
    );
  }
}
