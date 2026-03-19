import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser!;

    final roleColor = user.role == UserRole.admin ? AppTheme.accentCoral
        : user.role == UserRole.editor ? AppTheme.accentTeal
        : AppTheme.accentGold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true && context.mounted) provider.logout();
            },
            icon: const Icon(Icons.logout, color: Colors.white, size: 18),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryDeep, AppTheme.primaryNavy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: roleColor.withOpacity(0.2),
                    child: Text(
                      user.name.split(' ').take(2).map((n) => n[0]).join(),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: roleColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: roleColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      user.role.name.toUpperCase(),
                      style: TextStyle(color: roleColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SettingsTile(icon: Icons.favorite, label: 'My Favorites', subtitle: '${provider.favoriteStaff.length} saved', color: AppTheme.accentCoral, onTap: () {}),
                  _SettingsTile(icon: Icons.notifications, label: 'Notifications', subtitle: '${provider.unreadNotificationCount} unread', color: AppTheme.accentTeal, onTap: () {}),
                  if (user.role == UserRole.admin) ...[
                    const Divider(),
                    _SettingsTile(icon: Icons.admin_panel_settings, label: 'Admin Dashboard', subtitle: 'Manage staff & settings', color: AppTheme.accentCoral, onTap: () {}),
                  ],
                  if (user.role == UserRole.editor) ...[
                    const Divider(),
                    _SettingsTile(icon: Icons.edit, label: 'Department Editor', subtitle: user.department ?? 'Your department', color: AppTheme.accentTeal, onTap: () {}),
                  ],
                  const Divider(),
                  _SettingsTile(icon: Icons.info_outline, label: 'About App', subtitle: 'EduDirectory v1.0.0', color: AppTheme.primaryNavy, onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'EduDirectory',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2024 College Staff Directory',
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textMuted),
      onTap: onTap,
    );
  }
}
