import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/firebase_options.dart'; // ملف التهيئة المُولد عبر flutterfire
import 'login.dart'; // صفحة تسجيل الدخول
import 'home.dart';
import 'news_management.dart';
import 'academic_management.dart';
import 'register.dart';
import 'theme/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase قبل تشغيل التطبيق
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JPU AcademyBot Admin',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (ctx) => const AdminLoginPage(),
        '/register': (ctx) => const RegisterPage(),
        '/home': (ctx) => const HomePage(),
        '/news': (ctx) => const NewsManagementPage(),
        '/academic': (ctx) => const AcademicManagementPage(),
      },
    );
  }
}
