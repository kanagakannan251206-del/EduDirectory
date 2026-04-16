import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'package:flutter/material.dart';

class MockDataService {
  static List<StaffMember>? _cachedStaff;

  /// Loads all 14 Staff members from assets/data/staff.json
  static Future<List<StaffMember>> loadStaffFromAssets() async {
    if (_cachedStaff != null) return _cachedStaff!;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/staff.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final List<dynamic> staffList = jsonData['staff_members'];

      _cachedStaff = staffList.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        
        final String id = s['id'] ?? 's${i + 1}';
        final String name = (s['name'] ?? 'Unknown').toString().trim();
        final String dept = s['department'] ?? 'Artificial Intelligence and Data Science';
        
        // JSON mapping for NEC Staff Directory standards
        final String email = s['email_id'] ?? s['email'] ?? ''; 
        final String phone = s['ph_no'] ?? s['phone'] ?? '';
        
        final String? vidwan = s['vidwan_link'];
        final String? linkedin = s['linkedin_profile'];

        final bool isActualHod = (id == 'AI-001' || (s['designation']?.toString().contains('Head') ?? false));
        
        StaffRole role = StaffRole.staff;
        final String rawDesignation = (s['designation'] ?? '').toString().toLowerCase();
        
        if (isActualHod) {
          role = StaffRole.hod;
        } else if (rawDesignation.contains('associate')) {
          role = StaffRole.associateProfessor;
        } else if (rawDesignation.contains('assistant')) {
          role = StaffRole.assistantProfessor;
        } else if (rawDesignation.contains('professor')) {
          role = StaffRole.professor;
        }

        return StaffMember(
          id: id,
          name: name,
          email: email, 
          phone: phone,
          whatsapp: phone, 
          department: dept,
          role: role,
          designation: s['designation'] ?? 'Assistant Professor',
          employeeId: id,
          joiningDate: DateTime(2022, 1, 1),
          isEmergencyContact: isActualHod, 
          emergencyNote: isActualHod ? 'Head of Department' : '',
          isActive: true,
          availability: AvailabilityStatus.available,
          vidwanLink: vidwan,
          linkedinProfile: linkedin,
          profileImageUrl: '', // Fallback handled by UI
          qualification: '',
          specialization: '',
          bio: '',
        );
      }).toList();

      return _cachedStaff!;
    } catch (e) {
      debugPrint('Error loading staff data: $e');
      return [];
    }
  }

  static List<Department> getDepartments() {
    return [
      Department(
        id: 'd1',
        name: 'Artificial Intelligence and Data Science',
        code: 'AI&DS',
        description: 'Department of Artificial Intelligence and Data Science',
        building: 'Main Block',
        floor: '3rd Floor',
        phone: '9842637770',
        email: 'hodai@nec.edu.in',
        color: const Color(0xFF1A237E), 
      ),
    ];
  }

  static List<AppNotification> getNotifications() {
    return [
      AppNotification(
        id: 'n1',
        title: 'System Update',
        message: 'Staff profile editing is now restricted to individual owners.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'info',
      ),
    ];
  }

  /// Centralized User List for Authentication (Admin + 14 Staff)
  static List<AppUser> getUsers() {
    // 1. Primary Admin Account
    List<AppUser> users = [
      AppUser(
        id: 'admin_01', 
        name: 'NEC Admin', 
        email: 'admin@nec.edu.in', 
        role: UserRole.admin,
      ),
    ];

    // 2. All 14 Staff Members as Editors (from your JSON)
    final List<Map<String, String>> staffAccounts = [
      {"name": "Dr. V. Kalaivani", "email": "hodai@nec.edu.in"},
      {"name": "Dr. J. Naskath", "email": "naskat@nec.edu.in"},
      {"name": "Shenbagharaman A", "email": "shenbagharaman@gmail.com"},
      {"name": "V. Veera Anusuya", "email": "veeraanusuya_cse@nec.edu.in"},
      {"name": "K. Poorani", "email": "poorani-ai@nec.edu.in"},
      {"name": "P. Rampriya", "email": "rampriya-aids@nec.edu.in"},
      {"name": "Dhivya G", "email": "dhivya-aids@nec.edu.in"},
      {"name": "P. Swarna Gowsalya", "email": "swarna-aids@nec.edu.in"},
      {"name": "M. Saranya", "email": "saranyaai@nec.edu.in"},
      {"name": "N. Subhashini", "email": "subhashinidinakaran17@gmail.com"},
      {"name": "Jeyaseelan R", "email": "jeyaseelanmrj@gmail.com"},
      {"name": "Renganayaki .S", "email": "renganayaki.it@gmail.com"},
      {"name": "Madhubala R", "email": "madhubala.engineer@gmail.com"},
      {"name": "Ravirathinam Duraikannu", "email": "ravirathinam@gmail.com"},
    ];

    for (int i = 0; i < staffAccounts.length; i++) {
      users.add(AppUser(
        id: 'staff_${i + 1}',
        name: staffAccounts[i]['name']!,
        email: staffAccounts[i]['email']!,
        role: UserRole.editor, // Grants Editor Dashboard access
      ));
    }

    return users;
  }
}