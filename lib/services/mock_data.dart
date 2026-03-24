import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'package:flutter/material.dart';

class MockDataService {
  static List<StaffMember>? _cachedStaff;

  static Future<List<StaffMember>> loadStaffFromAssets() async {
    if (_cachedStaff != null) return _cachedStaff!;

    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/data/staff.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final List<dynamic> staffList = jsonData['staff_members'];

      _cachedStaff = staffList.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        
        // --- DATA EXTRACTION ---
        final String id = s['id'] ?? 's${i + 1}';
        
        // CRITICAL FOR CHATBOT: Trim name to ensure matching works perfectly
        final String name = (s['name'] ?? 'Unknown').toString().trim();
        
        // FIXED: Using the exact department name to match Dropdowns
        final String dept = s['department'] ?? 'Artificial Intelligence and Data Science';
        
        // MAPPING JSON KEYS (handling email_id and ph_no aliases)
        final String email = s['email_id'] ?? s['email'] ?? ''; 
        final String phone = s['ph_no'] ?? s['phone'] ?? '';
        
        // LINKS
        final String? vidwan = s['vidwan_link'];
        final String? linkedin = s['linkedin_profile'];

        // --- ROLE LOGIC ---
        // HOD Logic: Match by ID or Designation keyword
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
          joiningDate: DateTime(2020, 1, 1),
          isEmergencyContact: isActualHod, 
          emergencyNote: isActualHod ? 'Head of Department' : '',
          isActive: true,
          availability: AvailabilityStatus.available,
          vidwanLink: vidwan,
          linkedinProfile: linkedin,
          // Fallback for avatar logic in common_widgets
          profileImageUrl: '', 
          qualification: '',
          specialization: '',
          bio: '',
        );
      }).toList();

      return _cachedStaff!;
    } catch (e) {
      debugPrint('Error loading staff data from assets: $e');
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
        color: const Color(0xFF4361EE),
      ),
    ];
  }

  static List<AppNotification> getNotifications() {
    return [
      AppNotification(
        id: 'n1',
        title: 'Welcome to NEC Directory',
        message: 'The Staff directory is now live. Find and contact faculty easily.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        type: 'info',
      ),
    ];
  }

  static List<AppUser> getUsers() {
    return [
      AppUser(
        id: 'u1', 
        name: 'Admin', 
        email: 'admin@nec.edu.in', 
        role: UserRole.admin,
      ),
      AppUser(
        id: 'u2', 
        name: 'Student', 
        email: 'student@nec.edu.in', 
        role: UserRole.viewer, 
        studentId: 'STU-001',
      ),
    ];
  }
}
