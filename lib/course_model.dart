// lib/course_model.dart (ОНОВЛЕНО: Синхронізація з Firestore через Stream)

import 'package:flutter/material.dart';
import 'dart:async';
import 'repositories/course_repository.dart'; // ⭐️ Імпорт репозиторію ⭐️
import 'models/course.dart'; // Імпорт моделі Course

enum DataStatus { Initial, Loading, Loaded, Error }

class CourseModel extends ChangeNotifier {
  // ⭐️ Створюємо екземпляр репозиторію ⭐️
  final CourseRepository _courseRepository = CourseRepository();
  StreamSubscription<List<Course>>? _courseSubscription; // Для підписки на потік Firestore

  DataStatus _status = DataStatus.Initial;
  String? _errorMessage;
  String _searchQuery = '';
  
  // ⭐️ Зберігаємо всі завантажені об'єкти Course ⭐️
  List<Course> _allCourses = [];
  
  // Геттери
  DataStatus get status => _status;
  String? get errorMessage => _errorMessage;

  // Геттер для фільтрації
  List<Course> get _filteredAllCourses {
    if (_searchQuery.isEmpty) {
      return _allCourses;
    }
    final query = _searchQuery.toLowerCase();
    return _allCourses.where((course) {
      return course.title.toLowerCase().contains(query) ||
             course.description.toLowerCase().contains(query);
    }).toList();
  }

  // Публічні геттери для UI
  List<Course> get myCourses => _filteredAllCourses.where((c) => c.progress != null).toList();
  List<Course> get recommendedCourses => _filteredAllCourses.where((c) => c.progress == null).toList();

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners(); 
    }
  }

  // ⭐️ МЕТОД ЗАВАНТАЖЕННЯ: ПІДКЛЮЧЕННЯ ДО STREAM FIREBASE ⭐️
  void loadCourses() {
    // Якщо вже підписані, нічого не робимо
    if (_courseSubscription != null) return;

    _status = DataStatus.Loading;
    notifyListeners();

    // 1. Підписуємося на потік курсів з Firestore
    _courseSubscription = _courseRepository.getCoursesStream().listen(
      (courses) {
        // 2. Коли приходять нові дані (навіть якщо вони змінилися в консолі)
        _allCourses = courses;
        _status = DataStatus.Loaded;
        _errorMessage = null;
        notifyListeners(); // Сповіщення UI про свіжі дані
      },
      onError: (error) {
        // 3. Якщо сталася помилка
        _status = DataStatus.Error;
        _errorMessage = "Помилка синхронізації з Firestore: $error";
        notifyListeners();
      },
      onDone: () {
        // Опціонально: обробка завершення потоку
        print("Firestore stream completed.");
      }
    );
  }

  // Обов'язково очищаємо підписку при видаленні моделі
  @override
  void dispose() {
    _courseSubscription?.cancel();
    super.dispose();
  }
}