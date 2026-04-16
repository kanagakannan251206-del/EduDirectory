import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

// Essential imports for navigation
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
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Overview Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                'Overview', 
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                // FIXED: Changed from 1.6 to 1.3 to prevent text overflow on mobile
                childAspectRatio: 1.3, 
                children: [
                  _buildStatCard('Total Staff', '${stats['total']}', Icons.people, AppTheme.accentTeal),
                  _buildStatCard('Active', '${stats['active']}', Icons.check_circle, AppTheme.accentGreen),
                  _buildStatCard('Departments', '${stats['departments']}', Icons.business, AppTheme.accentGold),
                  _buildStatCard('Pending Reports', '0', Icons.report_problem, AppTheme.accentCoral),
                ],
              ),
            ),

            // --- Quick Actions ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Quick Actions', 
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildActionItem(context, 'Manage\nDepts', Icons.business, AppTheme.accentGold, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageDepartmentsScreen()))),
                  _buildActionItem(context, 'Add\nStaff', Icons.person_add_alt_1, AppTheme.accentGreen,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditStaffScreen()))),
                  _buildActionItem(context, 'Send\nAlert', Icons.notifications_active, AppTheme.accentTeal,
                    () => _showNotificationDialog(context)),
                  _buildActionItem(context, 'View\nReports', Icons.analytics, AppTheme.accentCoral, () {}),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SectionHeader(title: 'Staff by Department'),
            
            ...provider.departments.map((dept) {
              final deptStaff = provider.allStaff.where((s) => s.department == dept.name).toList();
              final count = deptStaff.length;
              
              return ExpansionTile(
                initiallyExpanded: true,
                leading: Container(
                  padding: const EdgeInsets.all(8), 
                  decoration: BoxDecoration(color: dept.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.school, color: dept.color, size: 20), 
                ),
                title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('$count members', style: const TextStyle(fontSize: 12)),
                children: deptStaff.map((s) => Opacity(
                  opacity: s.isActive ? 1.0 : 0.5,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: StaffAvatar(staff: s, radius: 18), 
                    title: Text(
                      s.name, 
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w500,
                        decoration: s.isActive ? TextDecoration.none : TextDecoration.lineThrough,
                      )
                    ),
                    subtitle: Text(s.isActive ? s.designation : "INACTIVE", style: const TextStyle(fontSize: 11)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryNavy),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditStaffScreen(staff: s))),
                        ),
                        Transform.scale(
                          scale: 0.75, 
                          child: Switch.adaptive(
                            value: s.isActive,
                            onChanged: (val) => provider.toggleStaffActive(s.id),
                            activeColor: AppTheme.accentGreen,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StaffDetailScreen(staffId: s.id))),
                  ),
                )).toList(),
              );
            }),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // FIXED STAT CARD: Optimized for mobile screen density
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value, 
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)
          ),
          const SizedBox(height: 2),
          Text(
            label, 
            style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // FIXED ACTION ITEM: Compacted for Row alignment
  Widget _buildActionItem(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label, 
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
            ),
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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Broadcast Alert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 10),
            TextField(controller: msgCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Message')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryNavy),
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && msgCtrl.text.isNotEmpty) {
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
                  const SnackBar(content: Text('Broadcast alert sent successfully'))
                );
              }
            },
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
