import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

// FIXED: Hide duplicate class to prevent navigation confusion
import '../viewer/staff_detail_screen.dart' hide AddEditStaffScreen; 
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
          NotificationBell(
            count: provider.unreadNotificationCount, 
            onTap: () {} 
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const AddEditStaffScreen())
        ),
        backgroundColor: AppTheme.accentGold,
        foregroundColor: AppTheme.primaryNavy,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Overview Stats Grid ---
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
                      StatsCard(label: 'Available', value: '${stats['available']}', icon: Icons.event_available, color: AppTheme.primaryNavy),
                    ],
                  ),
                ],
              ),
            ),

            // --- Quick Actions Row ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Actions', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _AdminAction(
                        icon: Icons.business, 
                        label: 'Manage\nDepts', 
                        color: AppTheme.accentGold, 
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageDepartmentsScreen()))
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _AdminAction(
                        icon: Icons.person_add, 
                        label: 'Add\nStaff', 
                        color: AppTheme.accentGreen, 
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditStaffScreen()))
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _AdminAction(
                        icon: Icons.notifications_active_outlined, 
                        label: 'Send\nAlert', 
                        color: AppTheme.accentTeal, 
                        onTap: () => _showNotificationDialog(context)
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _AdminAction(
                        icon: Icons.analytics_outlined, 
                        label: 'View\nReports', 
                        color: AppTheme.accentCoral, 
                        onTap: () {}
                      )),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Expandable Staff List by Department ---
            const SectionHeader(title: 'Directory Management'),
            ...provider.departments.map((dept) {
              final deptStaff = provider.getStaffByDepartment(dept.name);
              final count = deptStaff.length;
              
              return ExpansionTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: dept.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.school, color: dept.color, size: 20),
                ),
                title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Text('$count members'),
                children: deptStaff.map((s) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                  leading: StaffAvatar(staff: s, radius: 18),
                  title: Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text(s.designation, style: const TextStyle(fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryNavy),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditStaffScreen(staff: s))),
                      ),
                      // Toggle Active/Inactive Status using Provider
                      Switch.adaptive(
                        value: s.isActive,
                        onChanged: (val) => provider.toggleStaffActive(s.id),
                        activeColor: AppTheme.accentGreen,
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

  // --- Send Notification Helper ---
  void _showNotificationDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Broadcast Notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Alert Title')),
            const SizedBox(height: 8),
            TextField(controller: msgCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Message Body')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && msgCtrl.text.isNotEmpty) {
                // FIXED: Using real notification logic from AppProvider
                context.read<AppProvider>().addNotification(
                  AppNotification(
                    id: DateTime.now().millisecondsSinceEpoch.toString(), 
                    title: titleCtrl.text, 
                    message: msgCtrl.text, 
                    createdAt: DateTime.now(),
                    type: 'alert'
                  )
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Broadcast alert sent to all users.'))
                );
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
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
