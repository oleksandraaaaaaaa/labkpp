// lib/repositories/course_repository.dart (ПОВНИЙ КОД: Firestore + Storage)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // ⭐️ Імпорт Firebase Storage ⭐️
import '../models/course.dart';
import 'dart:io'; // Для роботи з File

// Назва колекції в Firestore
const String _courseCollection = 'courses';

class CourseRepository {
  // Ініціалізація екземпляра Firestore (для метаданих)
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // ⭐️ Ініціалізація екземпляра Storage (для файлів/зображень) ⭐️
  final FirebaseStorage _storage = FirebaseStorage.instance; 

  // ------------------------------------------------------------------
  // ⭐️ ЧИТАННЯ (READ) - Firestore (Завдання 4) ⭐️
  // ------------------------------------------------------------------
  Stream<List<Course>> getCoursesStream() {
    return _db.collection(_courseCollection)
      // Використовуємо withConverter для автоматичного перетворення DocumentSnapshot на об'єкт Course
      .withConverter<Course>(
        fromFirestore: Course.fromFirestore,
        toFirestore: (Course course, options) => course.toFirestore(),
      )
      .snapshots() // Повертає потік Snapshot'ів у реальному часі
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList()); 
  }

  // ------------------------------------------------------------------
  // ⭐️ CRUD ОПЕРАЦІЇ - Firestore (Завдання 5) ⭐️
  // ------------------------------------------------------------------
  
  // СТВОРЕННЯ (CREATE)
  Future<void> addCourse(Course course) async {
    // add() дозволяє Firestore автоматично згенерувати ID
    await _db.collection(_courseCollection).add(course.toFirestore());
  }

  // ОНОВЛЕННЯ (UPDATE)
  Future<void> updateCourse(Course course) async {
    // Використовуємо doc(course.id) для оновлення існуючого документа
    await _db.collection(_courseCollection)
      .doc(course.id) 
      // set() з merge: true оновлює лише вказані поля
      .set(course.toFirestore(), SetOptions(merge: true)); 
  }
  
  // ВИДАЛЕННЯ (DELETE)
  Future<void> deleteCourse(String id) async {
    await _db.collection(_courseCollection).doc(id).delete();
  }
  
  // ------------------------------------------------------------------
  // ⭐️ ЗБЕРІГАННЯ ФАЙЛІВ - Storage (Завдання 6) ⭐️
  // ------------------------------------------------------------------

  // МЕТОД: ЗАВАНТАЖЕННЯ ЗОБРАЖЕННЯ У FIREBASE STORAGE
  Future<String> uploadCourseImage(String courseId, File imageFile) async {
    // 1. Створення посилання на шлях (наприклад, 'course_images/ID/timestamp.jpg')
    // Використовуємо timestamp для унікальності, щоб уникнути кешування.
    final storageRef = _storage
        .ref()
        .child('course_images/$courseId/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // 2. Завантаження файлу
    final uploadTask = storageRef.putFile(imageFile);

    // 3. Очікування завершення завантаження
    final snapshot = await uploadTask.whenComplete(() => {});

    // 4. Отримання публічного URL для доступу до файлу
    final downloadUrl = await snapshot.ref.getDownloadURL();
    
    return downloadUrl;
  }
}