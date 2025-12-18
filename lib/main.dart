// lib/main.dart (ПОВНИЙ КОД)

import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'constants.dart';
// Provider
import 'package:provider/provider.dart'; 
import 'course_model.dart';
// SharedPreferences
import 'settings_service.dart'; // НОВИЙ ІМПОРТ

// Для Firebase Auth та Analytics
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

// ГЛОБАЛЬНИЙ ЕКЗЕМПЛЯР ДЛЯ ДОСТУПУ ДО ЛОКАЛЬНИХ ДАНИХ
final SettingsService settingsService = SettingsService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  //ІНІЦІАЛІЗАЦІЯ SharedPreferences
  await settingsService.init(); 
  
  // Ініціалізація Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 3Обгортка застосунку Provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => CourseModel(),
      child: const EducationApp(),
    ),
  );
}

class EducationApp extends StatelessWidget {
  const EducationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Education App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/main': (context) => const MainScreen(), 
      },
    );
  }
}