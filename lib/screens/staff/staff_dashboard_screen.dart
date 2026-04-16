import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/mock_data.dart';
import '../../models/models.dart';
import '../admin/add_edit_staff_screen.dart';

class StaffDashboardScreen extends StatefulWidget {
  final String loggedInUserEmail;

  const StaffDashboardScreen({super.key, required this.loggedInUserEmail});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  List<StaffMember> _allStaff = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  Future<void> _loadStaffData() async {
    final staff = await MockDataService.loadStaffFromAssets();
    setState(() {
      _allStaff = staff;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF26C6DA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                _buildStaffList(),
              ],
            ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text("NEC Staff Directory", 
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
        ),
      ],
    );
  }

  Widget _buildStaffList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final staff = _allStaff[index];
            bool isMe = staff.email.toLowerCase() == widget.loggedInUserEmail.toLowerCase();
            return _buildStaffCard(staff, isMe);
          },
          childCount: _allStaff.length,
        ),
      ),
    );
  }

  Widget _buildStaffCard(StaffMember staff, bool isMe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isMe ? Colors.cyanAccent : Colors.transparent,
          width: isMe ? 2 : 0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: isMe ? Colors.cyanAccent : Colors.white24,
          child: Text(staff.name[0], style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
        ),
        title: Text(staff.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(staff.designation, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        trailing: isMe 
          ? const Icon(Icons.edit_note, color: Colors.cyanAccent, size: 28) 
          : const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: () => _openStaffDetails(staff, isMe),
      ),
    );
  }

  void _openStaffDetails(StaffMember staff, bool isMe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StaffDetailSheet(
        staff: staff, 
        isMe: isMe,
        onEditRequest: () {
          Navigator.pop(context);
          _navigateToEditScreen(staff);
        },
      ),
    );
  }

  void _navigateToEditScreen(StaffMember staff) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditStaffScreen(
          staff: staff, 
          isEditing: true,
        ),
      ),
    ).then((_) => _loadStaffData());
  }
}

class _StaffDetailSheet extends StatelessWidget {
  final StaffMember staff;
  final bool isMe;
  final VoidCallback onEditRequest;

  const _StaffDetailSheet({
    required this.staff, 
    required this.isMe, 
    required this.onEditRequest
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 45, backgroundColor: Color(0xFF1A237E), child: Icon(Icons.person, color: Colors.white, size: 40)),
          const SizedBox(height: 16),
          Text(staff.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(staff.designation, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 24),
          _infoRow(Icons.email, staff.email, "mailto:${staff.email}"),
          // FIXED: Added ?? '' to handle null safety for phone
          _infoRow(Icons.phone, staff.phone ?? 'Not Available', "tel:${staff.phone ?? ''}"),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // FIXED: Added ?? '' to handle null safety for phone/socials
              _actionBtn(Icons.call, Colors.green, "tel:${staff.phone ?? ''}"),
              _actionBtn(Icons.chat, const Color(0xFF25D366), "https://wa.me/91${staff.phone ?? ''}"),
              if (staff.linkedinProfile != null)
                _actionBtn(Icons.link, const Color(0xFF0077B5), staff.linkedinProfile!),
            ],
          ),
          if (isMe) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onEditRequest,
              icon: const Icon(Icons.settings),
              label: const Text("Edit My Details"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String url) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A237E)),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: () async {
        if (label == 'Not Available' || label.isEmpty) return;
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
    );
  }

  Widget _actionBtn(IconData icon, Color color, String url) {
    return IconButton(
      icon: Icon(icon, color: color, size: 32),
      onPressed: () async {
        if (url.endsWith(':') || url.isEmpty) return; // Prevent launching empty links
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
    );
  }
}
