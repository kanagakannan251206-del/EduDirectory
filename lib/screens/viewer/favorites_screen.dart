import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../theme/app_theme.dart';
import 'staff_detail_screen.dart'; 

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // watch triggers a rebuild when any staff member is favorited/unfavorited
    final provider = context.watch<AppProvider>();
    final favs = provider.favoriteStaff;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('My Favorites'),
        centerTitle: true,
      ),
      body: favs.isEmpty
          // FIXED: Removed 'const' to support updated dynamic EmptyState widget
          ? EmptyState(
              icon: Icons.favorite_border_rounded, 
              title: 'No Favorites Yet',
              subtitle: 'Tap the heart icon on any staff profile to save them here for quick access.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: favs.length,
              itemBuilder: (ctx, i) {
                final s = favs[i];
                return StaffCard(
                  // Key ensures smooth animations when items are removed from the list
                  key: ValueKey(s.id),
                  staff: s,
                  isFavorite: true, 
                  onTap: () => Navigator.push(
                    ctx, 
                    MaterialPageRoute(
                      builder: (_) => StaffDetailScreen(staffId: s.id),
                    ),
                  ),
                  onFavoriteToggle: () => provider.toggleFavorite(s.id),
                );
              },
            ),
    );
  }
}
