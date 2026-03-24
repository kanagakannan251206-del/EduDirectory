import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EduDirectoryApp());
}

class EduDirectoryApp extends StatelessWidget {
  const EduDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..initialize(),
      child: MaterialApp(
        title: 'EduDirectory',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AppRoot(),
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    print('isLoading: ${provider.isLoading}');
    print('isLoggedIn: ${provider.isLoggedIn}');
    print('currentUser: ${provider.currentUser?.email}');

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.primaryNavy,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: 64, color: AppTheme.accentGold),
              SizedBox(height: 16),
              Text(
                'EduDirectory',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppTheme.accentGold),
            ],
          ),
        ),
      );
    }

    if (!provider.isLoggedIn) {
      return const LoginScreen();
    }

    return const MainShell();
  }
}