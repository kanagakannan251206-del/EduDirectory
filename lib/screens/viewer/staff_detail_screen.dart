import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class StaffDetailScreen extends StatelessWidget {
  final String staffId;
  const StaffDetailScreen({super.key, required this.staffId});

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final staff = provider.getStaffById(staffId);

    if (staff == null) {
      return const Scaffold(body: Center(child: Text('Staff member not found')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // --- Header with Photo ---
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppTheme.primaryNavy,
                flexibleSpace: FlexibleSpaceBar(
                  background: Center(
                    child: Hero(
                      tag: 'avatar-${staff.id}',
                      child: StaffAvatar(staff: staff, radius: 60),
                    ),
                  ),
                ),
              ),

              // --- Profile Info ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(staff.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      Text(staff.designation, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 20),
                      
                      // --- Professional Profiles Section (Matching Image) ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA), // Light grey background from image
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Professional Profiles",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF212529)),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildProfileChip(
                                  label: 'Vidwan',
                                  icon: Icons.school_outlined,
                                  onTap: () => _launchURL(staff.vidwanLink),
                                ),
                                const SizedBox(width: 10),
                                _buildProfileChip(
                                  label: 'LinkedIn',
                                  icon: FontAwesomeIcons.linkedin,
                                  color: const Color(0xFF0077B5),
                                  onTap: () => _launchURL(staff.linkedinProfile),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 120), // Spacer for the bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- Bottom Action Bar (Matching Image Layout) ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                children: [
                  // Call Button (Green)
                  Expanded(
                    flex: 4,
                    child: _buildMainActionButton(
                      label: 'Call',
                      icon: Icons.phone,
                      color: const Color(0xFF2ECC71),
                      onTap: () => _launchURL('tel:${staff.phone}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Email Button (Blue)
                  Expanded(
                    flex: 4,
                    child: _buildMainActionButton(
                      label: 'Email',
                      icon: Icons.email,
                      color: const Color(0xFF00B4D8),
                      onTap: () => _launchURL('mailto:${staff.email}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // WhatsApp Icon Button (Light Green Circle)
                  _buildIconActionButton(
                    icon: FontAwesomeIcons.whatsapp,
                    color: const Color(0xFFD8F3DC),
                    iconColor: const Color(0xFF25D366),
                    onTap: () => _launchURL('https://wa.me/${staff.phone}'),
                  ),
                  const SizedBox(width: 8),
                  // SMS Icon Button (Light Orange Circle)
                  _buildIconActionButton(
                    icon: Icons.chat_bubble,
                    color: const Color(0xFFFFF4E6),
                    iconColor: const Color(0xFFF39C12),
                    onTap: () => _launchURL('sms:${staff.phone}'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Styles for the Vidwan/LinkedIn Chips
  Widget _buildProfileChip({required String label, required IconData icon, Color? color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color != null ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color?.withOpacity(0.3) ?? const Color(0xFFCED4DA)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color ?? const Color(0xFF495057)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color ?? const Color(0xFF495057))),
          ],
        ),
      ),
    );
  }

  // Styles for Call/Email long buttons
  Widget _buildMainActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // Styles for WhatsApp/SMS circular buttons
  Widget _buildIconActionButton({required IconData icon, required Color color, required Color iconColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: iconColor.withOpacity(0.2)),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}
