# 🎓 EduDirectory — College Staff Directory App

A full-featured Flutter application for managing and browsing college faculty and staff.

---

## 📱 Screenshots Overview

| Login | Home | Staff Profile |
|-------|------|---------------|
| Dark gradient login with demo role selector | Dashboard with stats, departments, emergency banner | Tabbed profile: Overview, Academic, Schedule |

---

## 🚀 Getting Started (VS Code)

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / Xcode (for simulators)
- VS Code with **Flutter** and **Dart** extensions

### Setup Steps

```bash
# 1. Open the project in VS Code
cd college_staff_directory

# 2. Install dependencies
flutter pub get

# 3. Run on a device/emulator
flutter run

# OR run on specific platform
flutter run -d chrome        # Web
flutter run -d android       # Android
flutter run -d ios           # iOS (Mac only)
```

---

## 🏗️ Project Structure

```
lib/
├── main.dart                        # App entry point
├── theme/
│   └── app_theme.dart               # Colors, typography, theme data
├── models/
│   └── models.dart                  # StaffMember, Department, AppUser, etc.
├── providers/
│   └── app_provider.dart            # Central state management (Provider)
├── services/
│   └── mock_data.dart               # Sample staff & department data
├── widgets/
│   └── common_widgets.dart          # StaffCard, Avatar, SearchBar, etc.
└── screens/
    ├── login_screen.dart            # Login with demo accounts
    ├── main_shell.dart              # Bottom navigation shell
    ├── viewer/                      # Viewer/Student screens
    │   ├── home_screen.dart
    │   ├── directory_screen.dart
    │   ├── staff_detail_screen.dart
    │   ├── favorites_screen.dart
    │   ├── emergency_screen.dart
    │   ├── notifications_screen.dart
    │   ├── department_screen.dart
    │   ├── feedback_screen.dart
    │   ├── chatbot_screen.dart
    │   └── profile_screen.dart
    └── admin/                       # Admin screens
        ├── admin_dashboard_screen.dart
        ├── add_edit_staff_screen.dart
        └── manage_departments_screen.dart
```

---

## 👥 Role-Based Access

| Feature | Admin | Editor | Viewer |
|---------|-------|--------|--------|
| View Directory | ✅ | ✅ | ✅ |
| Search & Filter | ✅ | ✅ | ✅ |
| View Profiles | ✅ | ✅ | ✅ |
| Contact Faculty | ✅ | ✅ | ✅ |
| Favorites | ✅ | ✅ | ✅ |
| Chatbot | ✅ | ✅ | ✅ |
| Feedback | ✅ | ✅ | ✅ |
| Edit Staff | ✅ | ✅ (own dept) | ❌ |
| Add Staff | ✅ | ❌ | ❌ |
| Delete Staff | ✅ | ❌ | ❌ |
| Manage Departments | ✅ | ❌ | ❌ |
| Send Notifications | ✅ | ❌ | ❌ |
| Admin Dashboard | ✅ | ❌ | ❌ |

---

## 🎭 Demo Accounts

| Role | Email | Password |
|------|-------|----------|
| **Admin** | admin@college.edu | (any) |
| **Editor** (CS Dept) | cs.editor@college.edu | (any) |
| **Student/Viewer** | john@student.college.edu | (any) |

> 💡 In demo mode, any non-empty password works.

---

## ✨ Features

### For Students & Staff (Viewer)
- 🔍 **Smart Search** — search by name, subject, department, specialization, employee ID
- 🏫 **Department Browser** — colorful cards per department
- 👤 **Detailed Staff Profiles** — overview, academic info, schedule tabs
- 📞 **One-tap Contact** — Call, Email, WhatsApp, SMS, LinkedIn buttons
- ⭐ **Favorites** — save frequently visited profiles
- 🚨 **Emergency Contacts** — dedicated emergency screen with quick dial
- 🔔 **Notifications** — alerts and updates from admin
- 💬 **EduBot Chatbot** — guided assistant for navigating the directory
- 📝 **Feedback System** — submit feedback, reports, or update requests

### For Admins
- 📊 **Dashboard** — overview stats, quick actions
- ➕ **Add/Edit Staff** — full form with all fields
- 🏢 **Manage Departments** — view and update departments
- 📢 **Send Notifications** — broadcast messages to all users
- 🔄 **Toggle Active Status** — enable/disable staff visibility
- 📋 **Reports Management** — view submitted feedback

### For Editors
- ✏️ **Edit Department Staff** — update info for their department only

---

## 🔌 Backend Integration

The app uses `MockDataService` for demo data. To connect a real backend:

1. Create a `ApiService` class in `lib/services/`
2. Replace `MockDataService` calls in `AppProvider` with API calls
3. Use `dio` or `http` packages (already included)
4. Add authentication token handling in `shared_preferences`

Example API structure:
```
GET    /api/staff           — Get all staff
GET    /api/staff/:id       — Get staff by ID
POST   /api/staff           — Create staff (Admin)
PUT    /api/staff/:id       — Update staff (Admin/Editor)
DELETE /api/staff/:id       — Delete staff (Admin)
GET    /api/departments     — Get all departments
POST   /api/auth/login      — Login
GET    /api/notifications   — Get notifications
POST   /api/feedback        — Submit feedback
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `shared_preferences` | Local storage (favorites, auth) |
| `url_launcher` | Call, email, WhatsApp, SMS |
| `google_fonts` | DM Sans + Playfair Display |
| `font_awesome_flutter` | WhatsApp & LinkedIn icons |
| `uuid` | Generate unique IDs |
| `cached_network_image` | Profile photo caching |
| `fl_chart` | Admin dashboard charts |

---

## 🎨 Design System

- **Primary**: Deep Navy `#0D1B2A` / `#1B263B`
- **Accent Gold**: `#E8B84B`
- **Accent Teal**: `#00B4D8`
- **Accent Coral**: `#FF6B6B`
- **Success Green**: `#2DCE89`
- **Typography**: DM Sans (body) + Playfair Display (headings)

---

## 📄 License

MIT License — Free to use for educational and commercial projects.
