// lib/course_detail_screen.dart

import 'package:flutter/material.dart';
import 'constants.dart';

// ⭐️ СТРУКТУРА ДАНИХ ДЛЯ ДЕМОНСТРАЦІЇ ⭐️
// Ми будемо передавати всі необхідні дані на екран
class CourseDetailArguments {
  final String title;
  final String description;
  final List<String> contentItems;
  final String duration;
  final String format;
  final String level;

  CourseDetailArguments({
    required this.title,
    required this.description,
    required this.contentItems,
    this.duration = '6 тижнів',
    this.format = 'Онлайн',
    this.level = 'Базовий + впевнений',
  });
}

class CourseDetailScreen extends StatelessWidget {
  // Приймаємо аргументи через конструктор
  final CourseDetailArguments arguments; 
  
  const CourseDetailScreen({super.key, required this.arguments});

  // Допоміжний віджет для елементів "Що входить до курсу"
  Widget _buildContentItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.small / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5.0, right: AppSpacing.small / 2),
            child: Icon(Icons.circle, size: 5, color: AppColors.dark),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // Віджет для відображення відгуку
  Widget _buildReview(String name, String text, int stars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 12, backgroundColor: AppColors.secondary),
                const SizedBox(width: AppSpacing.small),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            // Відображення зірочок (рейтингу)
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < stars ? Icons.star : Icons.star_border,
                  color: AppColors.primary,
                  size: 16,
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.small / 2),
        Text(text, style: const TextStyle(fontSize: 14, color: AppColors.navItemColor)),
        const SizedBox(height: AppSpacing.large),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Статичні дані для відгуків (за макетом)
    final List<Map<String, dynamic>> reviews = [
      {'name': 'Alex Morningstar', 'text': 'Дуже скучно, але корисно', 'stars': 3},
      {'name': 'Янка', 'text': 'Очікувала більшого', 'stars': 2},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(arguments.title, style: const TextStyle(color: AppColors.dark)),
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.dark),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xLarge),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900), // Обмеження ширини для вебу
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------- ОСНОВНА СЕКЦІЯ -----------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ЛІВА ЧАСТИНА: Зображення та заголовок на зображенні
                    Expanded(
                      child: Container(
                        height: 400,
                        decoration: BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: BorderRadius.circular(10),
                          image: const DecorationImage(
                            image: NetworkImage('https://i.ibb.co/b38rF2Q/course-placeholder.png'), // Тимчасове зображення
                            fit: BoxFit.cover,
                            opacity: 0.5,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(AppSpacing.large),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('ПРАКТИКУМ', style: TextStyle(color: AppColors.white, fontSize: 16)),
                              Text('Алфавіт. Букви та звуки', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.large),

                    // ПРАВА ЧАСТИНА: Опис та Кнопка
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            arguments.title,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark),
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          Text(
                            arguments.description,
                            style: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.navItemColor),
                          ),
                          const SizedBox(height: AppSpacing.xLarge),
                          
                          // Блок з деталями
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Тривалість:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(arguments.duration),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Формат:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(arguments.format),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Рівень:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(arguments.level),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.xLarge),

                          // Кнопка Записатися
                          ElevatedButton(
                            onPressed: () {
                              // Бізнес-логіка не реалізується на даному етапі
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: AppColors.authPrimary,
                            ),
                            child: const Text('Записатися', style: TextStyle(fontSize: 18, color: AppColors.white)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xLarge * 2),
                const Divider(),
                const SizedBox(height: AppSpacing.large),

                // ----------------- ЩО ВХОДИТЬ ДО КУРСУ -----------------
                const Text(
                  'Що входить до курсу:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark),
                ),
                const SizedBox(height: AppSpacing.medium),

                // Список елементів курсу
                SizedBox(
                  width: 450, // Обмеження ширини для списку
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: arguments.contentItems.map(_buildContentItem).toList(),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xLarge * 2),

                // ----------------- ВІДГУКИ -----------------
                const Text(
                  'Відгуки:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.dark),
                ),
                const SizedBox(height: AppSpacing.medium),

                // Виведення статичних відгуків
                SizedBox(
                  width: 450, // Обмеження ширини для відгуків
                  child: Column(
                    children: reviews.map((r) => _buildReview(r['name'], r['text'], r['stars'])).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}