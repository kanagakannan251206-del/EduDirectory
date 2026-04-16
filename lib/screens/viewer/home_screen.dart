import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

// Essential imports for navigation
import 'staff_detail_screen.dart';
import 'department_screen.dart';
import 'emergency_screen.dart';
import 'directory_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    // FIX: logic for "Dr." name display
    String displayName = user?.name ?? 'Guest';
    if (user?.role == UserRole.editor && !displayName.startsWith('Dr.')) {
      displayName = 'Dr. $displayName';
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- Custom App Bar ---
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primaryNavy,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryDeep, AppTheme.primaryNavy],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$greeting,',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            NotificationBell(
                              count: provider.unreadNotificationCount,
                              onTap: () {}, 
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.school, color: AppTheme.accentGold, size: 14),
                              SizedBox(width: 6),
                              Text(
                                'NEC Staff Directory Portal',
                                style: TextStyle(
                                  color: AppTheme.accentGold, 
                                  fontSize: 12, 
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- Search Bar Section ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: AppSearchBar(
                hint: 'Search faculty, department...',
                onChanged: (q) {
                  provider.setSearchQuery(q);
                  if (q.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DirectoryScreen()),
                    );
                  }
                },
              ),
            ),
          ),

          // --- Quick Stats (Responsive Row) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickStat(
                      label: 'Faculty', 
                      value: '${provider.allStaff.where((s) => s.isActive).length}', 
                      icon: Icons.people, 
                      color: AppTheme.accentTeal
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickStat(
                      label: 'Dept', 
                      value: '${provider.departments.length}', 
                      icon: Icons.business, 
                      color: AppTheme.accentGold
                    )
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _QuickStat(
                      label: 'Available', 
                      value: '${provider.allStaff.where((s) => s.availability == AvailabilityStatus.available && s.isActive).length}', 
                      icon: Icons.check_circle, 
                      color: AppTheme.accentGreen
                    )
                  ),
                ],
              ),
            ),
          ),

          // --- Emergency Banner (Slim & Professional) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade800, Colors.red.shade900],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.15), 
                        blurRadius: 6, 
                        offset: const Offset(0, 3)
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emergency_outlined, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Emergency Contacts', 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
                            ),
                            Text(
                              '${provider.emergencyContacts.length} contacts available 24/7',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- Departments Section ---
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Departments',
              actionLabel: 'View All',
              onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DirectoryScreen())),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 130, 
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.departments.length,
                itemBuilder: (ctx, i) {
                  final dept = provider.departments[i];
                  final count = provider.departmentStaffCount[dept.name] ?? 0;
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    child: DepartmentCard(
                      department: dept,
                      staffCount: count,
                      onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => DepartmentScreen(department: dept),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // --- Featured Faculty Highlights ---
          SliverToBoxAdapter(child: SectionHeader(title: 'Faculty Highlights')),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final activeStaff = provider.allStaff.where((s) => s.isActive).toList();
                if (i >= activeStaff.length || i >= 5) return null; 
                final s = activeStaff[i];
                return StaffCard(
                  staff: s,
                  isFavorite: provider.isFavorite(s.id),
                  onTap: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(builder: (_) => StaffDetailScreen(staffId: s.id)),
                  ),
                  onFavoriteToggle: () => provider.toggleFavorite(s.id),
                );
              },
              childCount: _getSafeStaffCount(provider.allStaff),
            ),
          ),

          // --- View All Button ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DirectoryScreen())),
                icon: const Icon(Icons.search_sharp, size: 18),
                label: const Text('Explore All Faculty'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  int _getSafeStaffCount(List<StaffMember> list) {
    final activeCount = list.where((s) => s.isActive).length;
    return activeCount > 5 ? 5 : activeCount;
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _QuickStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value, 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)
                ),
                Text(
                  label, 
                  style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
