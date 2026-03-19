import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/mock_data.dart';

class AppProvider extends ChangeNotifier {
  // Auth
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Data
  List<StaffMember> _allStaff = [];
  List<Department> _departments = [];
  List<AppNotification> _notifications = [];
  List<String> _favorites = [];
  final List<FeedbackReport> _feedbacks = [];

  // Search & Filter
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  StaffRole? _selectedRole;
  AvailabilityStatus? _selectedAvailability;
  bool _showEmergencyOnly = false;

  // Chatbot
  List<Map<String, String>> _chatMessages = [];

  // Getters
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Department> get departments => _departments;
  List<String> get favorites => _favorites;
  List<AppNotification> get notifications => _notifications;
  List<FeedbackReport> get feedbacks => _feedbacks;
  String get searchQuery => _searchQuery;
  String get selectedDepartment => _selectedDepartment;
  StaffRole? get selectedRole => _selectedRole;
  AvailabilityStatus? get selectedAvailability => _selectedAvailability;
  bool get showEmergencyOnly => _showEmergencyOnly;
  List<Map<String, String>> get chatMessages => _chatMessages;
  bool get isLoggedIn => _currentUser != null;

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  List<StaffMember> get allStaff => _allStaff;

  List<StaffMember> get filteredStaff {
    return _allStaff.where((staff) {
      if (!staff.isActive) return false;
      if (_showEmergencyOnly && !staff.isEmergencyContact) return false;
      if (_selectedDepartment != 'All' && staff.department != _selectedDepartment) return false;
      if (_selectedRole != null && staff.role != _selectedRole) return false;
      if (_selectedAvailability != null && staff.availability != _selectedAvailability) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return staff.name.toLowerCase().contains(q) ||
            staff.department.toLowerCase().contains(q) ||
            staff.designation.toLowerCase().contains(q) ||
            staff.specialization.toLowerCase().contains(q) ||
            staff.employeeId.toLowerCase().contains(q) ||
            (staff.vidwanLink?.toLowerCase().contains(q) ?? false) ||
            (staff.linkedinProfile?.toLowerCase().contains(q) ?? false) ||
            staff.subjects.any((s) => s.toLowerCase().contains(q));
      }
      return true;
    }).toList();
  }

  List<StaffMember> get emergencyContacts =>
      _allStaff.where((s) => s.isEmergencyContact && s.isActive).toList();

  List<StaffMember> get favoriteStaff =>
      _allStaff.where((s) => _favorites.contains(s.id)).toList();

  List<StaffMember> getStaffByDepartment(String dept) =>
      _allStaff.where((s) => s.department == dept && s.isActive).toList();

  StaffMember? getStaffById(String id) =>
      _allStaff.where((s) => s.id == id).isNotEmpty
          ? _allStaff.firstWhere((s) => s.id == id)
          : null;

  bool isFavorite(String staffId) => _favorites.contains(staffId);

  Map<String, int> get departmentStaffCount {
    final map = <String, int>{};
    for (final dept in _departments) {
      map[dept.name] = _allStaff.where((s) => s.department == dept.name && s.isActive).length;
    }
    return map;
  }

  // --- Sorting Helper ---
  int _getRolePriority(StaffMember staff) {
    if (staff.id == 'AI-001' || staff.role == StaffRole.hod) return 1; // HOD first
    final d = staff.designation.toLowerCase();
    if (d.contains('associate')) return 2;
    if (d.contains('sr.grade')) return 3;
    if (d.contains('assistant professor')) return 4;
    if (d.contains('practice')) return 5;
    return 6;
  }

  // Init
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      List<StaffMember> staffData = await MockDataService.loadStaffFromAssets();
      
      // Apply Sorting: HOD first, then by designation priority
      staffData.sort((a, b) {
        int priorityA = _getRolePriority(a);
        int priorityB = _getRolePriority(b);
        if (priorityA != priorityB) {
          return priorityA.compareTo(priorityB);
        }
        // If same priority, keep ID order
        return a.id.compareTo(b.id);
      });

      _allStaff = staffData;
      _departments = MockDataService.getDepartments();
      _notifications = MockDataService.getNotifications();
      await _loadFromPrefs();
    } catch (e) {
      print('Initialize error: $e');
      _departments = MockDataService.getDepartments();
      _notifications = MockDataService.getNotifications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _favorites = prefs.getStringList('favorites') ?? [];
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        _currentUser = AppUser.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      print('Prefs error: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final users = MockDataService.getUsers();
    final matches = users.where(
      (u) => u.email.toLowerCase().trim() == email.toLowerCase().trim(),
    ).toList();

    if (matches.isNotEmpty) {
      _currentUser = matches.first;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
      } catch (e) {
        print('Prefs save error: $e');
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Email not found. Try admin@nec.edu.in';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    notifyListeners();
  }

  // Search & Filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedDepartment(String dept) {
    _selectedDepartment = dept;
    notifyListeners();
  }

  void setSelectedRole(StaffRole? role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setSelectedAvailability(AvailabilityStatus? status) {
    _selectedAvailability = status;
    notifyListeners();
  }

  void setShowEmergencyOnly(bool value) {
    _showEmergencyOnly = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedDepartment = 'All';
    _selectedRole = null;
    _selectedAvailability = null;
    _showEmergencyOnly = false;
    notifyListeners();
  }

  // Favorites
  Future<void> toggleFavorite(String staffId) async {
    if (_favorites.contains(staffId)) {
      _favorites.remove(staffId);
    } else {
      _favorites.add(staffId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }

  // Staff CRUD
  void addStaff(StaffMember staff) {
    _allStaff.add(staff);
    notifyListeners();
  }

  void updateStaff(StaffMember updated) {
    final idx = _allStaff.indexWhere((s) => s.id == updated.id);
    if (idx >= 0) {
      _allStaff[idx] = updated;
      notifyListeners();
    }
  }

  void deleteStaff(String id) {
    _allStaff.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void toggleStaffActive(String id) {
    final idx = _allStaff.indexWhere((s) => s.id == id);
    if (idx >= 0) {
      _allStaff[idx] = _allStaff[idx].copyWith(isActive: !_allStaff[idx].isActive);
      notifyListeners();
    }
  }

  void updateAvailability(String id, AvailabilityStatus status) {
    final idx = _allStaff.indexWhere((s) => s.id == id);
    if (idx >= 0) {
      _allStaff[idx] = _allStaff[idx].copyWith(availability: status);
      notifyListeners();
    }
  }

  // Departments
  void addDepartment(Department dept) {
    _departments.add(dept);
    notifyListeners();
  }

  void updateDepartment(Department dept) {
    final idx = _departments.indexWhere((d) => d.id == dept.id);
    if (idx >= 0) {
      _departments[idx] = dept;
      notifyListeners();
    }
  }

  // Notifications
  void markNotificationRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllNotificationsRead() {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Feedback
  void submitFeedback(FeedbackReport feedback) {
    _feedbacks.add(feedback);
    notifyListeners();
  }

  // Chatbot
  Future<void> sendChatMessage(String message) async {
    _chatMessages.add({'role': 'user', 'content': message});
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    final reply = _generateChatbotReply(message);
    _chatMessages.add({'role': 'assistant', 'content': reply});
    notifyListeners();
  }

  void clearChat() {
    _chatMessages = [];
    notifyListeners();
  }

  String _generateChatbotReply(String message) {
    final msg = message.toLowerCase();

    if (msg.contains('hello') || msg.contains('hi')) {
      return 'Hello! 👋 I\'m your College Directory Assistant. I can help you find faculty, departments, office hours, and more. What would you like to know?';
    }
    if (msg.contains('emergency') || msg.contains('urgent')) {
      return '🚨 For emergencies, please contact:\n• Dr. V. Kalaivani (HOD): +91-9842637770\n\nOr visit the Emergency Contacts section in the app.';
    }
    // ... rest of chatbot logic remains same ...
    return '🤖 I can help you with finding faculty or department information. What would you like to know?';
  }

  Map<String, dynamic> get adminStats {
    final total = _allStaff.length;
    final active = _allStaff.where((s) => s.isActive).length;
    final emergency = _allStaff.where((s) => s.isEmergencyContact).length;
    final available = _allStaff.where((s) => s.availability == AvailabilityStatus.available).length;
    return {
      'total': total,
      'active': active,
      'inactive': total - active,
      'emergency': emergency,
      'available': available,
      'departments': _departments.length,
      'pendingFeedback': _feedbacks.where((f) => f.status == 'pending').length,
    };
  }
}
