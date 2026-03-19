import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
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

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
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
                                  user?.name.split(' ').first ?? 'Guest',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Consumer<AppProvider>(
                              builder: (_, p, __) => NotificationBell(
                                count: p.unreadNotificationCount,
                                onTap: () {},
                              ),
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
                                'EduDirectory — College Staff Portal',
                                style: TextStyle(color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.w500),
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
                      MaterialPageRoute(builder: (_) => DirectoryScreen()),
                    );
                  }
                },
              ),
            ),
          ),

          // Quick Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: _QuickStat(label: 'Faculty', value: '${provider.allStaff.where((s) => s.isActive).length}', icon: Icons.people, color: AppTheme.accentTeal)),
                  const SizedBox(width: 12),
                  Expanded(child: _QuickStat(label: 'Departments', value: '${provider.departments.length}', icon: Icons.business, color: AppTheme.accentGold)),
                  const SizedBox(width: 12),
                  Expanded(child: _QuickStat(label: 'Available', value: '${provider.allStaff.where((s) => s.availability == AvailabilityStatus.available && s.isActive).length}', icon: Icons.check_circle, color: AppTheme.accentGreen)),
                ],
              ),
            ),
          ),

          // Emergency Contacts Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen())),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1744), Color(0xFFFF6B6B)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.emergency, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Emergency Contacts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                              '${provider.emergencyContacts.length} contacts available 24/7',
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Departments Section
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Departments',
              actionLabel: 'View All',
              onAction: () {},
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.departments.length,
                itemBuilder: (ctx, i) {
                  final dept = provider.departments[i];
                  final count = provider.departmentStaffCount[dept.name] ?? 0;
                  return Container(
                    width: 150,
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

          // Recent / Featured Staff
          const SliverToBoxAdapter(child: SectionHeader(title: 'Faculty Directory')),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final staff = provider.filteredStaff;
                if (i >= staff.length) return null;
                final s = staff[i];
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
              childCount: provider.filteredStaff.length > 5
                  ? 5
                  : provider.filteredStaff.length,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.people),
                label: Text('View All ${provider.allStaff.where((s) => s.isActive).length} Faculty'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
