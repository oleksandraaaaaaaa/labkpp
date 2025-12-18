// lib/course_form_model.dart (ВИПРАВЛЕНО: Додано логіку файлів та геттери/сеттери)

import 'package:flutter/material.dart';
import 'repositories/course_repository.dart';
import 'models/course.dart';
import 'dart:io'; // Для File

enum FormStatus { Initial, Submitting, Success, Error }

class CourseFormModel extends ChangeNotifier {
  final CourseRepository _courseRepository = CourseRepository();
  
  FormStatus _status = FormStatus.Initial;
  String? _errorMessage;

  // ⭐️ ДОДАНО: Змінна та геттер/сеттер для тимчасового зберігання вибраного файлу ⭐️
  File? _selectedImage;
  File? get selectedImage => _selectedImage;

  void setSelectedImage(File? image) {
    _selectedImage = image;
    notifyListeners();
  }

  FormStatus get status => _status;
  String? get errorMessage => _errorMessage;

  // ⭐️ МОДИФІКОВАНО: Метод тепер приймає imageFile ⭐️
  Future<void> saveCourse({
    required String? id, 
    required String title,
    required String description,
    required File? imageFile, // ⭐️ Додано imageFile як обов'язковий іменований параметр ⭐️
  }) async {
    if (title.isEmpty || description.isEmpty) {
      _errorMessage = "Заголовок та опис не можуть бути порожніми.";
      _status = FormStatus.Error;
      notifyListeners();
      return;
    }

    _status = FormStatus.Submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      String? imageUrl;
      
      // 1. ЗАВАНТАЖЕННЯ ЗОБРАЖЕННЯ У STORAGE (Завдання 6)
      if (imageFile != null) {
        final tempId = id ?? 'new_course_${DateTime.now().millisecondsSinceEpoch}';
        imageUrl = await _courseRepository.uploadCourseImage(tempId, imageFile);
      }

      // 2. ЗБЕРЕЖЕННЯ МЕТАДАНИХ У FIRESTORE
      final newCourse = Course(
        id: id ?? '', 
        title: title,
        description: description,
        progress: (id == null || id.isEmpty) ? null : '0%', 
        externalUrl: imageUrl, // Зберігаємо URL зображення
      );

      if (id == null || id.isEmpty) {
        await _courseRepository.addCourse(newCourse);
      } else {
        await _courseRepository.updateCourse(newCourse);
      }

      _status = FormStatus.Success;
    } catch (e) {
      _errorMessage = "Помилка збереження даних: $e";
      _status = FormStatus.Error;
    }

    notifyListeners();
  }
}