import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'views/screens/auth/login_screen.dart';
import 'utils/app_theme.dart';
import 'services/local/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables dari asset root .env
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('⚠️ Warning: Could not load .env file. Pastikan .env ada di root project dan terdaftar di pubspec.yaml: $e');
  }
  
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