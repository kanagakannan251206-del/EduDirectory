import 'package:flutter/material.dart';

enum StaffRole { professor, associateProfessor, assistantProfessor, lecturer, hod, dean, admin, staff }
enum UserRole { admin, editor, viewer }
enum AvailabilityStatus { available, busy, onLeave, offCampus }

extension StaffRoleExt on StaffRole {
  String get label {
    switch (this) {
      case StaffRole.professor: return 'Professor';
      case StaffRole.associateProfessor: return 'Associate Professor';
      case StaffRole.assistantProfessor: return 'Assistant Professor';
      case StaffRole.lecturer: return 'Lecturer';
      case StaffRole.hod: return 'Head of Department';
      case StaffRole.dean: return 'Dean';
      case StaffRole.admin: return 'Administrator';
      case StaffRole.staff: return 'Staff';
    }
  }
}

extension AvailabilityExt on AvailabilityStatus {
  String get label {
    switch (this) {
      case AvailabilityStatus.available: return 'Available';
      case AvailabilityStatus.busy: return 'Busy';
      case AvailabilityStatus.onLeave: return 'On Leave';
      case AvailabilityStatus.offCampus: return 'Off Campus';
    }
  }

  Color get color {
    switch (this) {
      case AvailabilityStatus.available: return const Color(0xFF2DCE89);
      case AvailabilityStatus.busy: return const Color(0xFFFF6B6B);
      case AvailabilityStatus.onLeave: return const Color(0xFFFFC107);
      case AvailabilityStatus.offCampus: return const Color(0xFF6C757D);
    }
  }
}

class OfficeHours {
  final String day;
  final String startTime;
  final String endTime;

  OfficeHours({required this.day, required this.startTime, required this.endTime});

  factory OfficeHours.fromJson(Map<String, dynamic> json) => OfficeHours(
    day: json['day'] ?? '',
    startTime: json['startTime'] ?? '',
    endTime: json['endTime'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'day': day,
    'startTime': startTime,
    'endTime': endTime,
  };
}

class StaffMember {
  final String id;
  final String name;
  final String email;
  final String? phone; 
  final String? whatsapp;
  final String department;
  final String? subDepartment;
  final StaffRole role;
  final String designation;
  final String? qualification;
  final String? specialization;
  final String? officeNumber;
  final String? officeLocation;
  final String? profileImageUrl;
  final String? bio;
  final List<String> subjects;
  final List<String> researchAreas;
  final List<String> publications;
  final List<OfficeHours> officeHours;
  final AvailabilityStatus availability;
  final bool isEmergencyContact;
  final String emergencyNote;
  final double rating;
  final int ratingCount;
  final DateTime joiningDate;
  final bool isActive;
  final String? employeeId;
  final Map<String, String> socialLinks;
  final bool isVerified;
  final String extension; 
  
  // Specific links from your staff.json
  final String? vidwanLink;
  final String? linkedinProfile;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.whatsapp = '',
    required this.department,
    this.subDepartment = '',
    required this.role,
    required this.designation,
    this.qualification = '',
    this.specialization = '',
    this.officeNumber = '',
    this.officeLocation = '',
    this.profileImageUrl = '',
    this.bio = '',
    this.subjects = const [],
    this.researchAreas = const [],
    this.publications = const [],
    this.officeHours = const [],
    this.availability = AvailabilityStatus.available,
    this.isEmergencyContact = false,
    this.emergencyNote = '',
    this.rating = 0.0,
    this.ratingCount = 0,
    required this.joiningDate,
    this.isActive = true,
    this.employeeId,
    this.socialLinks = const {},
    this.isVerified = false,
    this.extension = '',
    this.vidwanLink,
    this.linkedinProfile,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] ?? '', 
      name: json['name'] ?? '',
      // Handles both your JSON keys (email_id) and model keys (email)
      email: json['email_id'] ?? json['email'] ?? '',
      phone: json['ph_no'] ?? json['phone'],
      whatsapp: json['whatsapp'] ?? json['ph_no'] ?? '',
      department: json['department'] ?? '',
      subDepartment: json['subDepartment'] ?? '',
      role: StaffRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => StaffRole.staff,
      ),
      designation: json['designation'] ?? '',
      qualification: json['qualification'] ?? '',
      specialization: json['specialization'] ?? '',
      officeNumber: json['officeNumber'] ?? '',
      officeLocation: json['officeLocation'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      bio: json['bio'] ?? '',
      subjects: List<String>.from(json['subjects'] ?? []),
      researchAreas: List<String>.from(json['researchAreas'] ?? []),
      publications: List<String>.from(json['publications'] ?? []),
      officeHours: (json['officeHours'] as List? ?? [])
          .map((e) => OfficeHours.fromJson(e))
          .toList(),
      availability: AvailabilityStatus.values.firstWhere(
        (a) => a.name == json['availability'],
        orElse: () => AvailabilityStatus.available,
      ),
      isEmergencyContact: json['isEmergencyContact'] ?? false,
      emergencyNote: json['emergencyNote'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      joiningDate: DateTime.parse(json['joiningDate'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
      employeeId: json['employeeId'] ?? json['id'] ?? '',
      socialLinks: Map<String, String>.from(json['socialLinks'] ?? {}),
      isVerified: json['isVerified'] ?? false,
      extension: json['extension'] ?? '',
      // Links from staff.json
      vidwanLink: json['vidwan_link'] ?? json['vidwanLink'],
      linkedinProfile: json['linkedin_profile'] ?? json['linkedinProfile'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email_id': email, // Matching JSON export key
    'ph_no': phone,    // Matching JSON export key
    'whatsapp': whatsapp,
    'department': department,
    'subDepartment': subDepartment,
    'role': role.name,
    'designation': designation,
    'qualification': qualification,
    'specialization': specialization,
    'officeNumber': officeNumber,
    'officeLocation': officeLocation,
    'profileImageUrl': profileImageUrl,
    'bio': bio,
    'subjects': subjects,
    'researchAreas': researchAreas,
    'publications': publications,
    'officeHours': officeHours.map((e) => e.toJson()).toList(),
    'availability': availability.name,
    'isEmergencyContact': isEmergencyContact,
    'emergencyNote': emergencyNote,
    'rating': rating,
    'ratingCount': ratingCount,
    'joiningDate': joiningDate.toIso8601String(),
    'isActive': isActive,
    'employeeId': employeeId,
    'socialLinks': socialLinks,
    'isVerified': isVerified,
    'extension': extension,
    'vidwan_link': vidwanLink,
    'linkedin_profile': linkedinProfile,
  };

  StaffMember copyWith({
    String? id, String? name, String? email, String? phone, String? whatsapp,
    String? department, String? subDepartment, StaffRole? role, String? designation,
    String? qualification, String? specialization, String? officeNumber,
    String? officeLocation, String? profileImageUrl, String? bio,
    List<String>? subjects, List<String>? researchAreas, List<String>? publications,
    List<OfficeHours>? officeHours, AvailabilityStatus? availability,
    bool? isEmergencyContact, String? emergencyNote, double? rating, int? ratingCount,
    DateTime? joiningDate, bool? isActive, String? employeeId,
    Map<String, String>? socialLinks, bool? isVerified, String? extension,
    String? vidwanLink, String? linkedinProfile,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      department: department ?? this.department,
      subDepartment: subDepartment ?? this.subDepartment,
      role: role ?? this.role,
      designation: designation ?? this.designation,
      qualification: qualification ?? this.qualification,
      specialization: specialization ?? this.specialization,
      officeNumber: officeNumber ?? this.officeNumber,
      officeLocation: officeLocation ?? this.officeLocation,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      subjects: subjects ?? this.subjects,
      researchAreas: researchAreas ?? this.researchAreas,
      publications: publications ?? this.publications,
      officeHours: officeHours ?? this.officeHours,
      availability: availability ?? this.availability,
      isEmergencyContact: isEmergencyContact ?? this.isEmergencyContact,
      emergencyNote: emergencyNote ?? this.emergencyNote,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      joiningDate: joiningDate ?? this.joiningDate,
      isActive: isActive ?? this.isActive,
      employeeId: employeeId ?? this.employeeId,
      socialLinks: socialLinks ?? this.socialLinks,
      isVerified: isVerified ?? this.isVerified,
      extension: extension ?? this.extension,
      vidwanLink: vidwanLink ?? this.vidwanLink,
      linkedinProfile: linkedinProfile ?? this.linkedinProfile,
    );
  }
}

class Department {
  final String id;
  final String name;
  final String code;
  final String description;
  final String hodId;
  final String building;
  final String floor;
  final String phone;
  final String email;
  final Color color;
  final String iconName;
  final bool isActive;

  Department({
    required this.id,
    required this.name,
    required this.code,
    this.description = '',
    this.hodId = '',
    this.building = '',
    this.floor = '',
    this.phone = '',
    this.email = '',
    required this.color,
    this.iconName = 'school',
    this.isActive = true,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    code: json['code'] ?? '',
    description: json['description'] ?? '',
    hodId: json['hodId'] ?? '',
    building: json['building'] ?? '',
    floor: json['floor'] ?? '',
    phone: json['phone'] ?? '',
    email: json['email'] ?? '',
    color: Color(json['color'] ?? 0xFF4361EE),
    iconName: json['iconName'] ?? 'school',
    isActive: json['isActive'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'code': code, 'description': description,
    'hodId': hodId, 'building': building, 'floor': floor,
    'phone': phone, 'email': email, 'color': color.value,
    'iconName': iconName, 'isActive': isActive,
  };
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String type;
  final String? relatedId;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.type = 'info',
    this.relatedId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    message: json['message'] ?? '',
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    isRead: json['isRead'] ?? false,
    type: json['type'] ?? 'info',
    relatedId: json['relatedId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'message': message,
    'createdAt': createdAt.toIso8601String(), 'isRead': isRead,
    'type': type, 'relatedId': relatedId,
  };

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id, title: title, message: message, createdAt: createdAt,
    isRead: isRead ?? this.isRead, type: type, relatedId: relatedId,
  );
}

class FeedbackReport {
  final String id;
  final String staffId;
  final String reporterId;
  final String type;
  final String category;
  final String message;
  final DateTime createdAt;
  final String status;
  final double? rating;

  FeedbackReport({
    required this.id,
    required this.staffId,
    required this.reporterId,
    required this.type,
    required this.category,
    required this.message,
    required this.createdAt,
    this.status = 'pending',
    this.rating,
  });

  factory FeedbackReport.fromJson(Map<String, dynamic> json) => FeedbackReport(
    id: json['id'] ?? '',
    staffId: json['staffId'] ?? '',
    reporterId: json['reporterId'] ?? '',
    type: json['type'] ?? '',
    category: json['category'] ?? '',
    message: json['message'] ?? '',
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    status: json['status'] ?? 'pending',
    rating: json['rating']?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'staffId': staffId, 'reporterId': reporterId,
    'type': type, 'category': category, 'message': message,
    'createdAt': createdAt.toIso8601String(), 'status': status, 'rating': rating,
  };
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? department;
  final String profileImageUrl;
  final String studentId;
  final bool isActive;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.profileImageUrl = '',
    this.studentId = '',
    this.isActive = true,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    role: UserRole.values.firstWhere(
      (r) => r.name == json['role'],
      orElse: () => UserRole.viewer,
    ),
    department: json['department'],
    profileImageUrl: json['profileImageUrl'] ?? '',
    studentId: json['studentId'] ?? '',
    isActive: json['isActive'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email, 'role': role.name,
    'department': department, 'profileImageUrl': profileImageUrl,
    'studentId': studentId, 'isActive': isActive,
  };
}
