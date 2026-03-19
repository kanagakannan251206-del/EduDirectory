import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'feedback_screen.dart';

class StaffDetailScreen extends StatefulWidget {
  final String staffId;
  const StaffDetailScreen({super.key, required this.staffId});

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- HELPER METHOD FOR EMAILS ---
  Future<void> _launchEmail(BuildContext context, String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Query from NEC Staff Directory App'},
    );

    try {
      // mode: LaunchMode.externalApplication is critical for Gmail/Outlook
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Fallback: Copy to clipboard if launch fails
      await Clipboard.setData(ClipboardData(text: email));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email copied to clipboard: $email')),
        );
      }
    }
  }

  // --- GENERAL LAUNCHER ---
  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching $url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final staff = provider.getStaffById(widget.staffId);
    
    if (staff == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Staff Not Found')),
        body: const Center(child: Text('Staff member not found')),
      );
    }

    final color = AppTheme.getDepartmentColor(staff.department);
    final isFav = provider.isFavorite(staff.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                onPressed: () => provider.toggleFavorite(staff.id),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == 'feedback') {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => FeedbackScreen(staff: staff),
                    ));
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'feedback', child: Text('Feedback / Report')),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color.withOpacity(0.9), color],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              staff.name.split(' ').take(2).map((n) => n.isNotEmpty ? n[0] : '').join(),
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: staff.availability.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            staff.name,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          if (staff.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: Colors.white, size: 18),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.designation,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Badge(staff.department, Colors.white.withOpacity(0.2), Colors.white),
                          const SizedBox(width: 8),
                          _Badge(staff.availability.label, staff.availability.color.withOpacity(0.2), staff.availability.color),
                          if (staff.isEmergencyContact) ...[
                            const SizedBox(width: 8),
                            _Badge('Emergency', Colors.red.withOpacity(0.3), Colors.white),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: color,
                  unselectedLabelColor: AppTheme.textMuted,
                  indicatorColor: color,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Academic'),
                    Tab(text: 'Schedule'),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(staff: staff, color: color),
                _AcademicTab(staff: staff, color: color),
                _ScheduleTab(staff: staff, color: color),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ContactBar(
        staff: staff, 
        onEmailTap: () => _launchEmail(context, staff.email),
        onGenericLaunch: _launch,
      ),
    );
  }
}

// --- SHARED COMPONENTS ---

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
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final StaffMember staff;
  final Color color;
  const _OverviewTab({required this.staff, required this.color});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (staff.bio.isNotEmpty) ...[
            _SectionCard(
              title: 'About',
              child: Text(staff.bio, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 12),
          ],
          _SectionCard(
            title: 'Contact Information',
            child: Column(
              children: [
                _InfoRow(Icons.email, 'Email', staff.email),
                _InfoRow(Icons.phone, 'Phone', staff.phone),
                if (staff.extension.isNotEmpty)
                  _InfoRow(Icons.phone_forwarded, 'Extension', 'Ext. ${staff.extension}'),
                if (staff.officeNumber.isNotEmpty)
                  _InfoRow(Icons.location_on, 'Office', '${staff.officeNumber} — ${staff.officeLocation}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Professional Details',
            child: Column(
              children: [
                _InfoRow(Icons.badge, 'Employee ID', staff.employeeId),
                _InfoRow(Icons.school, 'Qualification', staff.qualification),
                _InfoRow(Icons.auto_awesome, 'Specialization', staff.specialization),
                _InfoRow(Icons.calendar_today, 'Joined', '${staff.joiningDate.year}'),
              ],
            ),
          ),
          if ((staff.vidwanLink?.isNotEmpty ?? false) || 
              (staff.linkedinProfile?.isNotEmpty ?? false) ||
              staff.linkedinUrl.isNotEmpty || 
              staff.personalWebsite.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Professional Profiles',
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (staff.vidwanLink != null && staff.vidwanLink!.isNotEmpty)
                      _SocialBtn(icon: Icons.school_outlined, label: 'Vidwan', color: AppTheme.primaryNavy, url: staff.vidwanLink!),
                    if (staff.linkedinProfile != null && staff.linkedinProfile!.isNotEmpty)
                      _SocialBtn(icon: FontAwesomeIcons.linkedinIn, label: 'LinkedIn', color: const Color(0xFF0077B5), url: staff.linkedinProfile!),
                    if (staff.linkedinUrl.isNotEmpty)
                      _SocialBtn(icon: FontAwesomeIcons.linkedin, label: 'LinkedIn Old', color: const Color(0xFF0077B5), url: staff.linkedinUrl),
                    if (staff.personalWebsite.isNotEmpty)
                      _SocialBtn(icon: Icons.language, label: 'Website', color: AppTheme.accentTeal, url: staff.personalWebsite),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AcademicTab extends StatelessWidget {
  final StaffMember staff;
  final Color color;
  const _AcademicTab({required this.staff, required this.color});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (staff.subjects.isNotEmpty) ...[
            _SectionCard(
              title: 'Subjects Taught',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: staff.subjects.map((s) => _Chip(s, color)).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (staff.researchAreas.isNotEmpty) ...[
            _SectionCard(
              title: 'Research Areas',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: staff.researchAreas.map((s) => _Chip(s, AppTheme.accentTeal)).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (staff.publications.isNotEmpty) ...[
            _SectionCard(
              title: 'Publications',
              child: Column(
                children: staff.publications.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${e.key + 1}. ', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                      Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13))),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  final StaffMember staff;
  final Color color;
  const _ScheduleTab({required this.staff, required this.color});

  @override
  Widget build(BuildContext context) {
    if (staff.officeHours.isEmpty) {
      return const EmptyState(
        icon: Icons.schedule,
        title: 'No Schedule',
        subtitle: 'Office hours not yet added',
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _SectionCard(
        title: 'Office Hours',
        child: Column(
          children: staff.officeHours.map((oh) => ListTile(
            leading: CircleAvatar(backgroundColor: color, child: Text(oh.day[0], style: const TextStyle(color: Colors.white))),
            title: Text(oh.day),
            subtitle: Text('${oh.startTime} - ${oh.endTime}'),
            contentPadding: EdgeInsets.zero,
          )).toList(),
        ),
      ),
    );
  }
}

class _ContactBar extends StatelessWidget {
  final StaffMember staff;
  final VoidCallback onEmailTap;
  final Function(String) onGenericLaunch;
  
  const _ContactBar({
    required this.staff, 
    required this.onEmailTap, 
    required this.onGenericLaunch
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => onGenericLaunch('tel:${staff.phone}'),
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onEmailTap,
              icon: const Icon(Icons.email, size: 18),
              label: const Text('Email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ContactIconBtn(
            icon: FontAwesomeIcons.whatsapp,
            color: const Color(0xFF25D366),
            onTap: () => onGenericLaunch('https://wa.me/${staff.phone.replaceAll(RegExp(r'[^\d]'), '')}'),
          ),
          const SizedBox(width: 8),
          _ContactIconBtn(
            icon: Icons.sms,
            color: AppTheme.accentGold,
            onTap: () => onGenericLaunch('sms:${staff.phone}'),
          ),
        ],
      ),
    );
  }
}

class _ContactIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ContactIconBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String url;
  const _SocialBtn({required this.icon, required this.label, required this.color, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('Error launching social link: $e');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
