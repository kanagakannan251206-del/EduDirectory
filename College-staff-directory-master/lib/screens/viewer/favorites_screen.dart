// favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import 'staff_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final favs = provider.favoriteStaff;

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: favs.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border,
              title: 'No Favorites Yet',
              subtitle: 'Tap the heart icon on any staff profile to save them here',
            )
          : ListView.builder(
              itemCount: favs.length,
              itemBuilder: (ctx, i) {
                final s = favs[i];
                return StaffCard(
                  staff: s,
                  isFavorite: true,
                  onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => StaffDetailScreen(staffId: s.id))),
                  onFavoriteToggle: () => provider.toggleFavorite(s.id),
                );
              },
            ),
    );
  }
}
