// lib/settings_service.dart

import 'package:shared_preferences/shared_preferences.dart';

// Ключ, за яким зберігається значення теми
const String _themeKey = 'preferred_theme_dark';

// Клас, що керує збереженням та читанням налаштувань.
class SettingsService {
  late SharedPreferences _prefs;

  // Асинхронний метод для ініціалізації SharedPreferences
  Future<void> init() async {
    //  Отримання єдиного екземпляра SharedPreferences 
    _prefs = await SharedPreferences.getInstance();
  }

  // Метод для збереження налаштування теми
  Future<void> saveThemeMode(bool isDark) async {
    // Збереження булевого значення за ключем 
    await _prefs.setBool(_themeKey, isDark);
  }

  // Метод для зчитування налаштування теми
  bool getThemeMode() {
    // Зчитування булевого значення. Повертає false, якщо значення відсутнє 
    return _prefs.getBool(_themeKey) ?? false;
  }
}