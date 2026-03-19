import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import 'staff_detail_screen.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final contacts = provider.emergencyContacts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: const Color(0xFFCC0000),
      ),
      body: CustomScrollView(
        slivers: [
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
                  const Icon(Icons.emergency, color: Color(0xFFCC0000), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emergency Contacts', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFFCC0000), fontWeight: FontWeight.bold)),
                        Text('These contacts are available for urgent academic and administrative needs.', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final staff = contacts[i];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.08), blurRadius: 8)],
                    border: Border.all(color: const Color(0xFFFF1744).withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 3,
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
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(staff.emergencyNote, style: const TextStyle(fontSize: 11, color: Color(0xFFCC0000))),
                              ),
                            ],
                          ],
                        ),
                        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => StaffDetailScreen(staffId: staff.id))),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _launch('tel:${staff.phone}'),
                                icon: const Icon(Icons.call, size: 16),
                                label: Text(staff.phone),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFCC0000),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () => _launch('mailto:${staff.email}'),
                              icon: const Icon(Icons.email, size: 16),
                              label: const Text('Email'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFCC0000),
                                side: const BorderSide(color: Color(0xFFCC0000)),
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
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
