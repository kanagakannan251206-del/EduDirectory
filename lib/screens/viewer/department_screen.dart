import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

// FIXED: Essential import for detail view navigation
import 'staff_detail_screen.dart';

class DepartmentScreen extends StatelessWidget {
  final Department department;
  const DepartmentScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final staff = provider.getStaffByDepartment(department.name);
    final color = department.color;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: CustomScrollView(
        slivers: [
          // --- Dynamic Header ---
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: color,
            elevation: 0,
            // FIXED: Removed invalid 'margin' from CircleAvatar
            leading: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          department.code, 
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8), 
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2
                          )
                        ),
                        const SizedBox(height: 4),
                        Text(
                          department.name, 
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 22, 
                            fontWeight: FontWeight.bold,
                            height: 1.2
                          )
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.people_outline, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${staff.length} Faculty Members', 
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- Department Info Row ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(Icons.location_on_outlined, '${department.building}, ${department.floor}', color),
                  _InfoChip(Icons.phone_outlined, department.phone, color),
                  _InfoChip(Icons.email_outlined, department.email, color),
                ],
              ),
            ),
          ),

          // --- Department Description ---
          if (department.description.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.1)),
                ),
                child: Text(
                  department.description, 
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)
                ),
              ),
            ),

          // --- Faculty List ---
          staff.isEmpty
              ? const SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.group_off,
                    title: 'No Faculty Listed',
                    subtitle: 'No members are currently assigned to this department.',
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final s = staff[i];
                      return StaffCard(
                        staff: s,
                        isFavorite: provider.isFavorite(s.id),
                        onTap: () => Navigator.push(
                          ctx, 
                          MaterialPageRoute(builder: (_) => StaffDetailScreen(staffId: s.id))
                        ),
                        onFavoriteToggle: () => provider.toggleFavorite(s.id),
                      );
                    },
                    childCount: staff.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label, 
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }
}
