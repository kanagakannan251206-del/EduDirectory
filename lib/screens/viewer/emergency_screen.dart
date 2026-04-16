import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

// FIXED: Essential import for navigation
import 'staff_detail_screen.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // watch triggers a rebuild whenever the emergencyContacts list in AppProvider updates
    final provider = context.watch<AppProvider>();
    final contacts = provider.emergencyContacts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: const Color(0xFFCC0000),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          // Header Information Card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFF1744).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emergency_share, color: Color(0xFFCC0000), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Primary Directory', 
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFCC0000), 
                            fontWeight: FontWeight.bold
                          )
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'These contacts are available for urgent academic and administrative needs.', 
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List of Emergency Contacts
          contacts.isEmpty
              ? SliverFillRemaining(
                  // FIXED: Removed 'const' keyword
                  child: EmptyState(
                    icon: Icons.contact_emergency_outlined,
                    title: 'No Emergency Contacts',
                    subtitle: 'No faculty members are currently marked as emergency contacts.',
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final staff = contacts[i];
                      final phoneNum = staff.phone ?? 'N/A';

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.08), 
                              blurRadius: 8, 
                              offset: const Offset(0, 4)
                            )
                          ],
                          border: Border.all(color: const Color(0xFFFF1744).withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            // Red accent bar at top
                            Container(
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF1744),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                            ),
                            ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: StaffAvatar(staff: staff, radius: 26, showBadge: false),
                              title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(staff.designation, style: const TextStyle(fontSize: 12)),
                                  if (staff.emergencyNote.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEBEE),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        staff.emergencyNote, 
                                        style: const TextStyle(fontSize: 11, color: Color(0xFFCC0000), fontWeight: FontWeight.bold)
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              onTap: () => Navigator.push(
                                ctx, 
                                MaterialPageRoute(builder: (_) => StaffDetailScreen(staffId: staff.id))
                              ),
                            ),
                            
                            // Action Buttons
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: staff.phone != null ? () => _launch('tel:${staff.phone}') : null,
                                      icon: const Icon(Icons.call, size: 16),
                                      label: Text(phoneNum),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFCC0000),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () => _launch('mailto:${staff.email}'),
                                    icon: const Icon(Icons.email_outlined, size: 16),
                                    label: const Text('Email'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFCC0000),
                                      side: const BorderSide(color: Color(0xFFCC0000)),
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: contacts.length,
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // Improved Launch Helper using url_launcher
  Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }
}
