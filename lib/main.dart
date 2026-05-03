import 'package:flutter/material.dart';
import 'views/screens/auth/login_screen.dart';
import 'utils/app_theme.dart';
import 'services/local/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const AstroEduApp());
}

class AstroEduApp extends StatelessWidget {
  const AstroEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroEdu',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}