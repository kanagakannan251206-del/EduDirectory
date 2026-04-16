import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class AddEditStaffScreen extends StatefulWidget {
  final StaffMember? staff;
  final bool isEditing; // Added to clarify intent from Staff Dashboard

  const AddEditStaffScreen({super.key, this.staff, this.isEditing = false});

  @override
  State<AddEditStaffScreen> createState() => _AddEditStaffScreenState();
}

class _AddEditStaffScreenState extends State<AddEditStaffScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _designationCtrl;
  late TextEditingController _qualificationCtrl;
  late TextEditingController _specializationCtrl;
  late TextEditingController _officeCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _linkedinCtrl;
  late TextEditingController _vidwanCtrl; 
  late TextEditingController _employeeIdCtrl;

  // Selection Variables
  String _selectedDept = 'Artificial Intelligence and Data Science'; 
  StaffRole _selectedRole = StaffRole.staff;
  AvailabilityStatus _availability = AvailabilityStatus.available;
  bool _isEmergencyContact = false;
  bool _isActive = true;

  bool get isUpdating => widget.staff != null;

  @override
  void initState() {
    super.initState();
    final s = widget.staff;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
    _phoneCtrl = TextEditingController(text: s?.phone ?? '');
    _designationCtrl = TextEditingController(text: s?.designation ?? '');
    _qualificationCtrl = TextEditingController(text: s?.qualification ?? '');
    _specializationCtrl = TextEditingController(text: s?.specialization ?? '');
    _officeCtrl = TextEditingController(text: s?.officeLocation ?? '');
    _bioCtrl = TextEditingController(text: s?.bio ?? '');
    _linkedinCtrl = TextEditingController(text: s?.linkedinProfile ?? '');
    _vidwanCtrl = TextEditingController(text: s?.vidwanLink ?? ''); 
    _employeeIdCtrl = TextEditingController(text: s?.employeeId ?? '');

    if (s != null) {
      _selectedDept = s.department;
      _selectedRole = s.role;
      _availability = s.availability;
      _isEmergencyContact = s.isEmergencyContact;
      _isActive = s.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _designationCtrl.dispose();
    _qualificationCtrl.dispose();
    _specializationCtrl.dispose();
    _officeCtrl.dispose();
    _bioCtrl.dispose();
    _linkedinCtrl.dispose();
    _vidwanCtrl.dispose(); 
    _employeeIdCtrl.dispose();
    super.dispose();
  }

  String? _nullIfEmpty(String value) => value.trim().isEmpty ? null : value.trim();

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = context.read<AppProvider>();
    
    final staff = StaffMember(
      id: widget.staff?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _nullIfEmpty(_phoneCtrl.text),
      department: _selectedDept,
      role: _selectedRole,
      designation: _designationCtrl.text.trim(),
      qualification: _nullIfEmpty(_qualificationCtrl.text),
      specialization: _nullIfEmpty(_specializationCtrl.text),
      officeLocation: _nullIfEmpty(_officeCtrl.text),
      bio: _nullIfEmpty(_bioCtrl.text),
      linkedinProfile: _nullIfEmpty(_linkedinCtrl.text),
      vidwanLink: _nullIfEmpty(_vidwanCtrl.text), 
      employeeId: _nullIfEmpty(_employeeIdCtrl.text) ?? 'EMP-${DateTime.now().millisecondsSinceEpoch}',
      joiningDate: widget.staff?.joiningDate ?? DateTime.now(),
      availability: _availability,
      isEmergencyContact: _isEmergencyContact,
      emergencyNote: _isEmergencyContact ? 'Emergency Contact' : '',
      isActive: _isActive,
    );

    if (isUpdating) {
      provider.updateStaff(staff);
    } else {
      provider.addStaff(staff);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isUpdating ? 'Profile updated successfully' : 'Staff added successfully'),
        backgroundColor: AppTheme.primaryNavy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    // Check if the current user is an Admin or just a Staff editing themselves
    final bool isAdmin = provider.currentUser?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: Text(isUpdating ? 'Update Profile' : 'Add New Staff'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Section(
                title: 'Basic Information',
                children: [
                  _Field(controller: _nameCtrl, label: 'Full Name', icon: Icons.person, required: true),
                  _Field(
                    controller: _emailCtrl, 
                    label: 'Email Address', 
                    icon: Icons.email, 
                    keyboardType: TextInputType.emailAddress, 
                    required: true,
                    enabled: isAdmin, // Only Admin can change official email
                  ),
                  _Field(controller: _phoneCtrl, label: 'Phone Number', icon: Icons.phone, keyboardType: TextInputType.phone),
                  _Field(controller: _employeeIdCtrl, label: 'Employee ID', icon: Icons.badge, enabled: isAdmin),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Department & Role',
                children: [
                  // Disable Department selection for Staff
                  DropdownButtonFormField<String>(
                    value: _selectedDept, 
                    decoration: const InputDecoration(labelText: 'Department', prefixIcon: Icon(Icons.business)),
                    items: provider.departments.map((d) => DropdownMenuItem(value: d.name, child: Text(d.name))).toList(),
                    onChanged: isAdmin ? (v) => setState(() => _selectedDept = v!) : null,
                  ),
                  const SizedBox(height: 12),
                  // Disable Role selection for Staff
                  DropdownButtonFormField<StaffRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Staff Category', prefixIcon: Icon(Icons.work)),
                    items: StaffRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(),
                    onChanged: isAdmin ? (v) => setState(() => _selectedRole = v!) : null,
                  ),
                  const SizedBox(height: 12),
                  _Field(controller: _designationCtrl, label: 'Designation', icon: Icons.title, required: true, enabled: isAdmin),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Academic & Professional',
                children: [
                  _Field(controller: _qualificationCtrl, label: 'Qualification', icon: Icons.school),
                  _Field(controller: _specializationCtrl, label: 'Specialization', icon: Icons.auto_awesome),
                  _Field(controller: _officeCtrl, label: 'Office Location', icon: Icons.location_on),
                  _Field(controller: _bioCtrl, label: 'Short Bio', icon: Icons.description, maxLines: 3),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Professional Links',
                children: [
                  _Field(controller: _linkedinCtrl, label: 'LinkedIn Profile URL', icon: Icons.link, keyboardType: TextInputType.url),
                  _Field(controller: _vidwanCtrl, label: 'Vidwan Profile URL', icon: Icons.school, keyboardType: TextInputType.url),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Status & Visibility',
                children: [
                  DropdownButtonFormField<AvailabilityStatus>(
                    value: _availability,
                    decoration: const InputDecoration(labelText: 'Current Availability', prefixIcon: Icon(Icons.sensors)),
                    items: AvailabilityStatus.values.map((a) => DropdownMenuItem(
                      value: a,
                      child: Row(children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: a.color, shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Text(a.label),
                      ]),
                    )).toList(),
                    onChanged: (v) => setState(() => _availability = v!),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: _isEmergencyContact,
                    onChanged: isAdmin ? (v) => setState(() => _isEmergencyContact = v) : null,
                    title: const Text('Emergency Contact'),
                    subtitle: const Text('Mark as priority contact for the department'),
                    activeColor: AppTheme.accentCoral,
                  ),
                  SwitchListTile(
                    value: _isActive,
                    onChanged: isAdmin ? (v) => setState(() => _isActive = v) : null,
                    title: const Text('Directory Visibility'),
                    subtitle: const Text('Show profile in the public directory'),
                    activeColor: AppTheme.accentGreen,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(isUpdating ? Icons.check_circle : Icons.person_add),
                  label: Text(isUpdating ? 'Save Changes' : 'Create Staff Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy)),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool required;
  final int maxLines;
  final bool enabled;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.required = false,
    this.maxLines = 1,
    this.enabled = true,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        enabled: enabled,
        keyboardType: keyboardType,
        style: TextStyle(color: enabled ? Colors.black87 : Colors.grey),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: Icon(icon, size: 20),
          filled: !enabled,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: required ? (v) => v!.isEmpty ? 'This field is required' : null : null,
      ),
    );
  }
}
