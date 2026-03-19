import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

// ── Staff Avatar Widget ────────────────────────────────────────────────────────
class StaffAvatar extends StatelessWidget {
  final StaffMember staff;
  final double radius;
  final bool showBadge;

  const StaffAvatar({
    super.key,
    required this.staff,
    this.radius = 28,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getDepartmentColor(staff.department);
    final initials = staff.name.split(' ').where((n) => n.isNotEmpty).take(2).map((n) => n[0].toUpperCase()).join();

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: color.withOpacity(0.15),
          backgroundImage: staff.profileImageUrl.isNotEmpty
              ? NetworkImage(staff.profileImageUrl)
              : null,
          child: staff.profileImageUrl.isEmpty
              ? Text(
                  initials,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.6,
                  ),
                )
              : null,
        ),
        if (showBadge)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: radius * 0.55,
              height: radius * 0.55,
              decoration: BoxDecoration(
                color: staff.availability.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Staff Card ────────────────────────────────────────────────────────────────
class StaffCard extends StatelessWidget {
  final StaffMember staff;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const StaffCard({
    super.key,
    required this.staff,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getDepartmentColor(staff.department);
    final bool isHOD = staff.role == StaffRole.hod;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Subtle border and different shadow for HOD
          border: isHOD ? Border.all(color: color.withOpacity(0.4), width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: isHOD ? color.withOpacity(0.1) : Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  StaffAvatar(staff: staff),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                staff.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isHOD ? color : null, 
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (staff.isVerified || isHOD)
                              Icon(Icons.verified, 
                                  color: isHOD ? color : AppTheme.accentTeal, 
                                  size: 16),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          staff.designation,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isHOD ? color.withOpacity(0.8) : AppTheme.textSecondary,
                                fontWeight: isHOD ? FontWeight.bold : FontWeight.normal,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        _Badge(
                          staff.department, 
                          color.withOpacity(0.1), 
                          color
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onFavoriteToggle,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isFavorite),
                        color: isFavorite ? AppTheme.accentCoral : AppTheme.textMuted,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Quick Actions Section with Vidwan and LinkedIn
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _QuickAction(
                      icon: Icons.phone,
                      label: 'Call',
                      color: AppTheme.accentGreen,
                      onTap: () => _launchUrl('tel:${staff.phone}'),
                    ),
                    const SizedBox(width: 10),
                    _QuickAction(
                      icon: Icons.email,
                      label: 'Email',
                      color: AppTheme.accentTeal,
                      onTap: () => _launchUrl('mailto:${staff.email}'),
                    ),
                    const SizedBox(width: 10),
                    _QuickAction(
                      icon: FontAwesomeIcons.whatsapp,
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      onTap: () => _launchUrl(
                        'https://wa.me/${staff.phone.replaceAll(RegExp(r'[^\d]'), '')}',
                      ),
                    ),
                    // Only show LinkedIn if link exists
                    if (staff.linkedinProfile != null && staff.linkedinProfile!.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      _QuickAction(
                        icon: FontAwesomeIcons.linkedinIn,
                        label: 'LinkedIn',
                        color: const Color(0xFF0077B5),
                        onTap: () => _launchUrl(staff.linkedinProfile!),
                      ),
                    ],
                    // Only show Vidwan if link exists
                    if (staff.vidwanLink != null && staff.vidwanLink!.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      _QuickAction(
                        icon: Icons.school_outlined,
                        label: 'Vidwan',
                        color: AppTheme.primaryNavy,
                        onTap: () => _launchUrl(staff.vidwanLink!),
                      ),
                    ],
                    const SizedBox(width: 10),
                    _QuickAction(
                      icon: Icons.sms,
                      label: 'SMS',
                      color: AppTheme.accentGold,
                      onTap: () => _launchUrl('sms:${staff.phone}'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url');
    }
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Badge(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label, 
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600)
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Department Card ────────────────────────────────────────────────────────────
class DepartmentCard extends StatelessWidget {
  final Department department;
  final int staffCount;
  final VoidCallback onTap;

  const DepartmentCard({
    super.key,
    required this.department,
    required this.staffCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              department.color,
              department.color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: department.color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    department.code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              department.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$staffCount faculty',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────
class AppSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final String initialValue;

  const AppSearchBar({
    super.key,
    this.hint = 'Search faculty...',
    required this.onChanged,
    this.initialValue = '',
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
          suffixIcon: _controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onChanged('');
                    setState(() {});
                  },
                  child: const Icon(Icons.clear, color: AppTheme.textMuted),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Notification Bell ─────────────────────────────────────────────────────────
class NotificationBell extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const NotificationBell({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
          if (count > 0)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppTheme.accentCoral,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count > 9 ? '9+' : count.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: AppTheme.primaryNavy.withOpacity(0.3)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Stats Card ─────────────────────────────────────────────────────────────────
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
