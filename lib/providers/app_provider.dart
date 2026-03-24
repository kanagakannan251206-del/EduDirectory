import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/mock_data.dart';

class AppProvider extends ChangeNotifier {
  // --- State Variables ---
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  List<StaffMember> _allStaff = [];
  List<Department> _departments = [];
  List<AppNotification> _notifications = [];
  List<String> _favorites = [];
  final List<FeedbackReport> _feedbacks = [];

  // Search & Filter State
  String _searchQuery = '';
  String _selectedDepartment = 'All';
  StaffRole? _selectedRole;
  AvailabilityStatus? _selectedAvailability;
  bool _showEmergencyOnly = false;

  // Chatbot State
  List<Map<String, String>> _chatMessages = [];

  // --- Getters ---
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
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;
  List<StaffMember> get allStaff => _allStaff;

  // --- Search & Filter Logic ---
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
            (staff.specialization?.toLowerCase().contains(q) ?? false) ||
            (staff.employeeId?.toLowerCase().contains(q) ?? false) ||
            (staff.vidwanLink?.toLowerCase().contains(q) ?? false) ||
            (staff.linkedinProfile?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();
  }

  List<StaffMember> get emergencyContacts =>
      _allStaff.where((s) => s.isEmergencyContact && s.isActive).toList();

  List<StaffMember> get favoriteStaff =>
      _allStaff.where((s) => _favorites.contains(s.id)).toList();

  List<StaffMember> getStaffByDepartment(String deptName) =>
      _allStaff.where((s) => s.department == deptName && s.isActive).toList();

  Map<String, int> get departmentStaffCount {
    final map = <String, int>{};
    for (final dept in _departments) {
      map[dept.name] = _allStaff.where((s) => s.department == dept.name && s.isActive).length;
    }
    return map;
  }

  // --- Initialization & Persistence ---
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedStaffJson = prefs.getString('persisted_staff_data');
      
      List<StaffMember> staffData;
      if (savedStaffJson != null) {
        // Load from Local Storage (added/edited staff)
        final List<dynamic> decoded = jsonDecode(savedStaffJson);
        staffData = decoded.map((item) => StaffMember.fromJson(item)).toList();
      } else {
        // First run: Load from assets
        staffData = await MockDataService.loadStaffFromAssets();
      }
      
      // Apply Sorting
      staffData.sort((a, b) {
        int priorityA = _getRolePriority(a);
        int priorityB = _getRolePriority(b);
        if (priorityA != priorityB) return priorityA.compareTo(priorityB);
        return (a.employeeId ?? '').compareTo(b.employeeId ?? '');
      });

      _allStaff = staffData;
      _departments = MockDataService.getDepartments();
      _notifications = MockDataService.getNotifications();
      await _loadFromPrefs();
    } catch (e) {
      debugPrint('Initialize error: $e');
      _departments = MockDataService.getDepartments();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveStaffToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedData = jsonEncode(_allStaff.map((s) => s.toJson()).toList());
      await prefs.setString('persisted_staff_data', encodedData);
    } catch (e) {
      debugPrint('Failed to save staff data: $e');
    }
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = prefs.getStringList('favorites') ?? [];
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      _currentUser = AppUser.fromJson(jsonDecode(userJson));
    }
  }

  // --- Staff CRUD ---
  void addStaff(StaffMember staff) {
    _allStaff.add(staff);
    _saveStaffToLocal();
    notifyListeners();
  }

  void updateStaff(StaffMember updated) {
    final idx = _allStaff.indexWhere((s) => s.id == updated.id);
    if (idx >= 0) {
      _allStaff[idx] = updated;
      _saveStaffToLocal();
      notifyListeners();
    }
  }

  void deleteStaff(String id) {
    _allStaff.removeWhere((s) => s.id == id);
    _saveStaffToLocal();
    notifyListeners();
  }

  void toggleStaffActive(String id) {
    final idx = _allStaff.indexWhere((s) => s.id == id);
    if (idx >= 0) {
      _allStaff[idx] = _allStaff[idx].copyWith(isActive: !_allStaff[idx].isActive);
      _saveStaffToLocal();
      notifyListeners();
    }
  }

  // --- Filter & UI Actions ---
  void setSearchQuery(String query) { _searchQuery = query; notifyListeners(); }
  void setSelectedDepartment(String dept) { _selectedDepartment = dept; notifyListeners(); }
  void setSelectedRole(StaffRole? role) { _selectedRole = role; notifyListeners(); }
  void setSelectedAvailability(AvailabilityStatus? status) { _selectedAvailability = status; notifyListeners(); }
  void setShowEmergencyOnly(bool value) { _showEmergencyOnly = value; notifyListeners(); }
  
  void clearFilters() {
    _searchQuery = '';
    _selectedDepartment = 'All';
    _selectedRole = null;
    _selectedAvailability = null;
    _showEmergencyOnly = false;
    notifyListeners();
  }

  // --- Notification Logic ---
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
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

  // --- Real-Time Chatbot Logic (Smart Search) ---
  void clearChat() { _chatMessages = []; notifyListeners(); }

  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;
    _chatMessages.add({'role': 'user', 'content': message});
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    final reply = _generateChatbotReply(message);
    _chatMessages.add({'role': 'assistant', 'content': reply});
    notifyListeners();
  }

  String _generateChatbotReply(String message) {
    final msg = message.toLowerCase();

    // 1. Department Count Logic
    if (msg.contains('how many') || msg.contains('count')) {
      final deptMatch = _departments.firstWhere(
        (d) => msg.contains(d.name.toLowerCase()) || msg.contains(d.code.toLowerCase()),
        orElse: () => Department(id: '', name: '', code: '', color: Colors.transparent),
      );

      if (deptMatch.name.isNotEmpty) {
        final count = _allStaff.where((s) => s.department == deptMatch.name).length;
        return 'There are $count staff members in the ${deptMatch.name} department.';
      }
      return 'There are ${_allStaff.length} total staff members in the directory.';
    }

    // 2. Global Search Logic (Matches any staff by name)
    StaffMember? foundStaff;
    try {
      foundStaff = _allStaff.firstWhere((s) {
        // Matches if the user input contains any part of the staff's name (e.g., Dhivya)
        final nameParts = s.name.toLowerCase().split(RegExp(r'[\s.] +'));
        return nameParts.any((part) => part.length > 3 && msg.contains(part));
      });
    } catch (_) { /* No match found */ }

    if (foundStaff != null) {
      if (msg.contains('phone') || msg.contains('contact') || msg.contains('number') || msg.contains('mobile')) {
        return '${foundStaff.name}\'s phone number is ${foundStaff.phone ?? "not listed"}.';
      }
      if (msg.contains('email') || msg.contains('mail') || msg.contains('id')) {
        return 'The email address for ${foundStaff.name} is ${foundStaff.email}.';
      }
      return '${foundStaff.name} is a ${foundStaff.designation} in ${foundStaff.department}. Status: ${foundStaff.availability.label}.';
    }

    // 3. HOD Logic
    if (msg.contains('hod') || msg.contains('head')) {
      final hod = _allStaff.firstWhere((s) => s.role == StaffRole.hod, orElse: () => _allStaff.first);
      return 'The HOD is ${hod.name}. You can reach them at ${hod.email}.';
    }

    return '🤖 I can find phone numbers, staff counts, or HOD details. Try asking "How many staff in AI?" or "What is Saranya\'s email?"';
  }

  // --- Auth & Sorting Helpers ---
  int _getRolePriority(StaffMember s) {
    if (s.role == StaffRole.hod) return 1;
    if (s.designation.toLowerCase().contains('associate')) return 2;
    if (s.designation.toLowerCase().contains('assistant professor')) return 3;
    return 4;
  }

  Future<bool> login(String email, String pass) async {
    _isLoading = true; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    final users = MockDataService.getUsers();
    final match = users.where((u) => u.email.toLowerCase() == email.toLowerCase().trim());
    if (match.isNotEmpty) {
      _currentUser = match.first;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
      _isLoading = false; notifyListeners();
      return true;
    }
    _isLoading = false; notifyListeners();
    return false;
  }

  void logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    notifyListeners();
  }

  // --- Admin Stats ---
  Map<String, dynamic> get adminStats => {
    'total': _allStaff.length,
    'active': _allStaff.where((s) => s.isActive).length,
    'departments': _departments.length,
    'available': _allStaff.where((s) => s.availability == AvailabilityStatus.available).length,
    'pendingFeedback': _feedbacks.where((f) => f.status == 'pending').length,
  };

  StaffMember? getStaffById(String id) => _allStaff.any((s) => s.id == id) ? _allStaff.firstWhere((s) => s.id == id) : null;
  bool isFavorite(String id) => _favorites.contains(id);
  
  void toggleFavorite(String id) async {
    _favorites.contains(id) ? _favorites.remove(id) : _favorites.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }
}
