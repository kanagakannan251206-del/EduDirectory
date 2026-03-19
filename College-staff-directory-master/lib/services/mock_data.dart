import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';
import 'package:flutter/material.dart';

class MockDataService {
  static List<StaffMember>? _cachedStaff;

  static Future<List<StaffMember>> loadStaffFromAssets() async {
    if (_cachedStaff != null) return _cachedStaff!;

    try {
      final String jsonString = await rootBundle.loadString('assets/data/staff.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final List<dynamic> staffList = jsonData['staff_members'];

      _cachedStaff = staffList.asMap().entries.map((entry) {
        final i = entry.key;
        final s = entry.value;
        
        // Basic Info extraction
        final String id = s['id'] ?? 's${i + 1}';
        final String name = s['name'] ?? 'Unknown';
        final String dept = s['department'] ?? 'AI & DS';
        
        // CRITICAL FOR EMAIL: Ensure the key matches your JSON exactly
        final String email = s['email_id'] ?? ''; 
        final String phone = s['ph_no'] ?? '';
        
        // Capturing the Vidwan and LinkedIn fields from JSON
        final vidwan = s['vidwan_link'];
        final linkedin = s['linkedin_profile'];

        // HOD RULE: Only Dr. V. Kalaivani (AI-001) gets the HOD role
        final bool isActualHod = (id == 'AI-001');
        final role = isActualHod ? StaffRole.hod : StaffRole.lecturer;

        // DESIGNATION: Take exactly what's in the JSON (e.g., Associate Professor)
        final designation = s['designation'] ?? (isActualHod ? 'Professor & Head' : 'Assistant Professor');

        return StaffMember(
          id: id,
          name: name,
          email: email, // This feeds the blue Email button
          phone: phone,
          whatsapp: phone, // WhatsApp uses the phone number
          department: dept,
          role: role,
          designation: designation,
          employeeId: id,
          joiningDate: DateTime(2020, 1, 1),
          isEmergencyContact: isActualHod, 
          emergencyNote: isActualHod ? 'Head of Department' : '',
          isActive: true,
          availability: AvailabilityStatus.available,
          vidwanLink: vidwan,
          linkedinProfile: linkedin,
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
        code: 'AIDS',
        description: 'AI, Machine Learning and Data Science',
        building: 'Block A',
        floor: '3rd',
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
        message: 'Staff directory is now live. Find and contact faculty easily.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        type: 'info',
      ),
    ];
  }

  static List<AppUser> getUsers() {
    return [
      AppUser(id: 'u1', name: 'Admin', email: 'admin@nec.edu.in', role: UserRole.admin),
      AppUser(id: 'u2', name: 'Student', email: 'student@nec.edu.in', role: UserRole.viewer, studentId: 'STU-001'),
    ];
  }
}
