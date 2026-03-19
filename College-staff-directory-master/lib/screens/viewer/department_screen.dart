// department_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.9), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(department.code, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                        Text(department.name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${staff.length} faculty members', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (department.description.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(department.description, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _InfoChip(Icons.location_on, '${department.building}, ${department.floor}', color),
                  const SizedBox(width: 8),
                  _InfoChip(Icons.phone, department.phone, color),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final s = staff[i];
                return StaffCard(
                  staff: s,
                  isFavorite: provider.isFavorite(s.id),
                  onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => StaffDetailScreen(staffId: s.id))),
                  onFavoriteToggle: () => provider.toggleFavorite(s.id),
                );
              },
              childCount: staff.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
