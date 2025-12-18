// lib/models/course.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Клас, що представляє єдину задачу
class Task {
  final String label;
  final String time;

  Task({required this.label, required this.time});
  
  // Метод для створення об'єкта Task з JSON (мапи)
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      label: json['label'] as String? ?? 'Невідома задача',
      time: json['time'] as String? ?? '00:00:00',
    );
  }
}

// Клас, що представляє єдиний курс
class Course {
  final String id;
  final String title;
  final String description;
  final String? progress; // null, якщо це рекомендований курс
  final String? externalUrl;

  Course({
    required this.id,
    required this.title,
    required this.description,
    this.progress,
    this.externalUrl,
  });

  // ⭐️ Фабричний конструктор для створення об'єкта Course з Документа Firestore ⭐️
  factory Course.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Course(
      id: snapshot.id, // ID беремо з самого DocumentSnapshot
      title: data?['title'] as String? ?? 'Без назви',
      description: data?['description'] as String? ?? 'Немає опису',
      progress: data?['progress'] as String?, // Опціональний
      externalUrl: data?['externalUrl'] as String?,
    );
  }

  // ⭐️ Метод для перетворення об'єкта Course на формат, придатний для запису у Firestore ⭐️
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      if (progress != null) 'progress': progress,
      if (externalUrl != null) 'externalUrl': externalUrl,
    };
  }
}