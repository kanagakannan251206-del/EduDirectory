import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class AddEditStaffScreen extends StatefulWidget {
  final StaffMember? staff;
  const AddEditStaffScreen({super.key, this.staff});

  @override
  State<AddEditStaffScreen> createState() => _AddEditStaffScreenState();
}

class _AddEditStaffScreenState extends State<AddEditStaffScreen> {
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

  bool get isEditing => widget.staff != null;

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
    // FIXED: Changed linkedinUrl to linkedinProfile
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
      // FIXED: parameter name changed to linkedinProfile
      linkedinProfile: _nullIfEmpty(_linkedinCtrl.text),
      vidwanLink: _nullIfEmpty(_vidwanCtrl.text), 
      employeeId: _nullIfEmpty(_employeeIdCtrl.text) ?? 'EMP-${DateTime.now().millisecondsSinceEpoch}',
      joiningDate: widget.staff?.joiningDate ?? DateTime.now(),
      availability: _availability,
      isEmergencyContact: _isEmergencyContact,
      emergencyNote: _isEmergencyContact ? 'Emergency Contact' : '',
      isActive: _isActive,
    );

    if (isEditing) {
      provider.updateStaff(staff);
    } else {
      provider.addStaff(staff);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isEditing ? 'Staff updated successfully' : 'Staff added successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(title: Text(isEditing ? 'Edit Staff' : 'Add New Staff')),
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
                  _Field(controller: _emailCtrl, label: 'Email Address', icon: Icons.email, keyboardType: TextInputType.emailAddress, required: true),
                  _Field(controller: _phoneCtrl, label: 'Phone Number', icon: Icons.phone, keyboardType: TextInputType.phone),
                  _Field(controller: _employeeIdCtrl, label: 'Employee ID', icon: Icons.badge),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Department & Role',
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedDept, 
                    decoration: const InputDecoration(labelText: 'Department', prefixIcon: Icon(Icons.business)),
                    items: provider.departments.map((d) => DropdownMenuItem(value: d.name, child: Text(d.name))).toList(),
                    onChanged: (v) => setState(() => _selectedDept = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<StaffRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.work)),
                    items: StaffRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.label))).toList(),
                    onChanged: (v) => setState(() => _selectedRole = v!),
                  ),
                  const SizedBox(height: 12),
                  _Field(controller: _designationCtrl, label: 'Designation', icon: Icons.title, required: true),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Academic Details',
                children: [
                  _Field(controller: _qualificationCtrl, label: 'Qualification', icon: Icons.school),
                  _Field(controller: _specializationCtrl, label: 'Specialization', icon: Icons.auto_awesome),
                  _Field(controller: _officeCtrl, label: 'Office Location', icon: Icons.location_on),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Profile & Links',
                children: [
                  _Field(controller: _bioCtrl, label: 'Bio', icon: Icons.description, maxLines: 3),
                  _Field(controller: _linkedinCtrl, label: 'LinkedIn URL', icon: Icons.link, keyboardType: TextInputType.url),
                  _Field(controller: _vidwanCtrl, label: 'Vidwan URL', icon: Icons.school, keyboardType: TextInputType.url),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Status',
                children: [
                  DropdownButtonFormField<AvailabilityStatus>(
                    value: _availability,
                    decoration: const InputDecoration(labelText: 'Availability', prefixIcon: Icon(Icons.circle)),
                    items: AvailabilityStatus.values.map((a) => DropdownMenuItem(
                      value: a,
                      child: Row(children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(color: a.color, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(a.label),
                      ]),
                    )).toList(),
                    onChanged: (v) => setState(() => _availability = v!),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _isEmergencyContact,
                    onChanged: (v) => setState(() => _isEmergencyContact = v),
                    title: const Text('Emergency Contact'),
                    subtitle: const Text('Show in emergency contacts list'),
                    activeColor: AppTheme.accentCoral,
                  ),
                  SwitchListTile(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    title: const Text('Active'),
                    subtitle: const Text('Show in directory'),
                    activeColor: AppTheme.accentGreen,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(isEditing ? Icons.save : Icons.person_add),
                  label: Text(isEditing ? 'Update Staff' : 'Add Staff'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(height: 40),
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
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
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
  final TextInputType? keyboardType;
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: Icon(icon),
        ),
        validator: required ? (v) => v!.isEmpty ? 'Required' : null : null,
      ),
    );
  }
}
