import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../viewer/staff_detail_screen.dart';
import 'add_edit_staff_screen.dart';
import 'manage_departments_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final stats = provider.adminStats;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          NotificationBell(count: provider.unreadNotificationCount, onTap: () {}),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditStaffScreen())),
        backgroundColor: AppTheme.accentGold,
        foregroundColor: AppTheme.primaryNavy,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats Grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      StatsCard(label: 'Total Staff', value: '${stats['total']}', icon: Icons.people, color: AppTheme.accentTeal),
                      StatsCard(label: 'Active', value: '${stats['active']}', icon: Icons.check_circle, color: AppTheme.accentGreen),
                      StatsCard(label: 'Departments', value: '${stats['departments']}', icon: Icons.business, color: AppTheme.accentGold),
                      StatsCard(label: 'Pending Reports', value: '${stats['pendingFeedback']}', icon: Icons.report, color: AppTheme.accentCoral),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Actions', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _AdminAction(icon: Icons.business, label: 'Manage\nDepartments', color: AppTheme.accentGold, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageDepartmentsScreen())))),
                      const SizedBox(width: 10),
                      Expanded(child: _AdminAction(icon: Icons.person_add, label: 'Add\nStaff', color: AppTheme.accentGreen, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditStaffScreen())))),
                      const SizedBox(width: 10),
                      Expanded(child: _AdminAction(icon: Icons.notifications, label: 'Send\nNotification', color: AppTheme.accentTeal, onTap: () => _showNotificationDialog(context))),
                      const SizedBox(width: 10),
                      Expanded(child: _AdminAction(icon: Icons.report, label: 'View\nReports', color: AppTheme.accentCoral, onTap: () {})),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Staff by Department
            const SectionHeader(title: 'Staff by Department'),
            ...provider.departments.map((dept) {
              final count = provider.departmentStaffCount[dept.name] ?? 0;
              final deptStaff = provider.getStaffByDepartment(dept.name);
              return ExpansionTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: dept.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.school, color: dept.color, size: 20),
                ),
                title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('$count members'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$count', style: TextStyle(color: dept.color, fontWeight: FontWeight.bold)),
                    const Icon(Icons.expand_more),
                  ],
                ),
                children: deptStaff.map((s) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                  leading: StaffAvatar(staff: s, radius: 18),
                  title: Text(s.name, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(s.role.label, style: const TextStyle(fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditStaffScreen(staff: s))),
                      ),
                      Switch(
                        value: s.isActive,
                        onChanged: (_) => provider.toggleStaffActive(s.id),
                        activeThumbColor: AppTheme.accentGreen,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StaffDetailScreen(staffId: s.id))),
                )).toList(),
              );
            }),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Send Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: msgCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Message')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && msgCtrl.text.isNotEmpty) {
                context.read<AppProvider>().addNotification(AppNotification(
                  id: DateTime.now().toString(),
                  title: titleCtrl.text,
                  message: msgCtrl.text,
                  createdAt: DateTime.now(),
                  type: 'info',
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

class _AdminAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AdminAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
