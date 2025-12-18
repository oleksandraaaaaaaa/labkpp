// lib/home_screen.dart (ОНОВЛЕНО: Додано кнопки CRUD)

import 'package:flutter/material.dart';
import 'constants.dart';
import 'auth_screen.dart';
// ІМПОРТИ ДЛЯ ЛР №5/6
import 'package:provider/provider.dart'; 
import 'course_model.dart'; 
import 'settings_service.dart';
import 'main.dart'; 
import 'course_detail_screen.dart';
import 'models/course.dart'; 
import 'course_form_screen.dart'; // ⭐️ Імпорт екрана форми ⭐️
import 'repositories/course_repository.dart'; // Для прямого видалення


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Дані
  static const String _userName = 'Олександро';
  int _selectedSidebarIndex = 0;

  // Контролери скролінгу
  final PageController _myCoursesPageController = PageController();
  int _currentPageMy = 0;
  
  // Контролер для поля Пошуку (для UI)
  final TextEditingController _searchController = TextEditingController(); 

  // Дані для секцій (залишаємо тільки назви та іконки)
  final List<String> _pageTitles = ['Головна', 'Курси', 'Мої курси'];
  final List<IconData> _pageIcons = [Icons.home, Icons.folder_open, Icons.person];

  // Статичні задачі (для демонстрації ListView)
  final List<Task> myTasks = [
    Task(label: 'Лекція 1. Speaking', time: '00:40:00'),
    Task(label: 'Лекція 3. Основи HTML', time: '00:10:00'),
    Task(label: 'Завдання 2. Виконати вправи Speaking', time: '00:20:00'),
    Task(label: 'Лекція 5. Основи Dart', time: '01:00:00'),
    Task(label: 'Завдання 4. Звіт по ЛР5', time: '02:00:00'),
  ];


  @override
  void initState() {
    super.initState();
    _myCoursesPageController.addListener(() {
      int next = _myCoursesPageController.page?.round() ?? 0;
      if (_currentPageMy != next) {
        setState(() {
          _currentPageMy = next;
        });
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseModel>(context, listen: false).loadCourses();
    });
    
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    Provider.of<CourseModel>(context, listen: false).setSearchQuery(query);
  }

  @override
  void dispose() {
    _myCoursesPageController.dispose();
    _searchController.removeListener(_onSearchChanged); 
    _searchController.dispose(); 
    super.dispose();
  }

  // ⭐️ НОВИЙ МЕТОД: Контекстне меню для Редагування/Видалення (Завдання 5) ⭐️
  void _showCourseActions(Course course) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0), // Позиція меню (умовна)
      items: [
        PopupMenuItem(
          value: 'edit',
          child: const Text('Редагувати'),
          onTap: () {
            // Перехід на форму редагування
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CourseFormScreen(courseToEdit: course),
            ));
          },
        ),
        PopupMenuItem(
          value: 'delete',
          child: const Text('Видалити'),
          onTap: () async {
            // Видалення через репозиторій. Provider автоматично оновить список.
            await CourseRepository().deleteCourse(course.id);
          },
        ),
      ],
    );
  }


  // --- ДОПОМІЖНІ ВІДЖЕТИ ---

  Widget _buildSidebarItem(int index, String title, IconData icon) {
    bool isSelected = _selectedSidebarIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSidebarIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large, vertical: AppSpacing.medium),
        margin: const EdgeInsets.only(right: AppSpacing.medium),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(5),
              )
            : null,
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.navItemColor),
            const SizedBox(width: AppSpacing.small),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.navItemColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDemoSettings() {
    bool isDarkMode = settingsService.getThemeMode();
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Темний режим (Demo SharedPreferences)', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
          ),
          Switch(
            value: isDarkMode,
            onChanged: (newValue) async {
              await settingsService.saveThemeMode(newValue);
              setState(() { /* Оновлюємо стан, щоб перечитати значення */ }); 
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // GridView.builder - для рекомендованих курсів 
  Widget _buildRecommendedCourses(List<Course> courses) {
    if (courses.isEmpty) {
      return const Center(
        child: Text('Курси не знайдені за вашим запитом.'),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Рекомендовані курси (GridView)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.small),

        SizedBox(
          height: 350, 
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              crossAxisSpacing: AppSpacing.medium,
              mainAxisSpacing: AppSpacing.medium,
              childAspectRatio: 1.5,
            ),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return InkWell( 
                onTap: () {
                   Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CourseDetailScreen(
                        arguments: CourseDetailArguments(
                          title: course.title,
                          description: course.description,
                          contentItems: const [
                            'Повний розбір усіх тем, що входять до програми HMT',
                            'Теоретичні матеріали у зручному форматі',
                            'Практичні тести з поясненнями правильних відповідей',
                            'Завдання для самоперевірки після кожного модуля',
                            'Підсумковий тест, максимально наближений до реального НМТ',
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ⭐️ Кнопка "Редагувати/Видалити" для рекомендованих курсів ⭐️
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.school, color: AppColors.primary, size: 30),
                          // Виклик контекстного меню
                          IconButton(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onPressed: () => _showCourseActions(course), 
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        course.title, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        course.description, 
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Секція "Мої курси" (PageView)
  Widget _buildMyCoursesSection(List<Course> courses) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Text('У вас немає активних курсів.'),
            // ⭐️ Кнопка "Створити курс" (Додано для Завдання 5) ⭐️
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CourseFormScreen(),
                ));
              },
              child: const Text('Створити новий курс'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Мої курси',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // ⭐️ Кнопка "Створити курс" (Додано для Завдання 5) ⭐️
            TextButton.icon(
              icon: const Icon(Icons.add, color: AppColors.primary),
              label: const Text('Створити', style: TextStyle(color: AppColors.primary)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CourseFormScreen(),
                ));
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.small / 2),

        // Горизонтальний скролінг (PageView)
        SizedBox(
          height: 300, 
          child: PageView.builder(
            controller: _myCoursesPageController,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return GestureDetector(
                onLongPress: () => _showCourseActions(course), // ⭐️ Додано LongPress для CRUD ⭐️
                child: Container(
                  margin: const EdgeInsets.only(right: AppSpacing.medium),
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           Text(course.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                           // Кнопка дій (наприклад, для моїх курсів)
                           IconButton(
                            icon: const Icon(Icons.more_vert, size: 20),
                            onPressed: () => _showCourseActions(course), 
                           ),
                        ],
                      ),
                      const Spacer(),
                      Text('Прогрес: ${course.progress!}', style: const TextStyle(color: Colors.grey)),
                      LinearProgressIndicator(value: double.tryParse(course.progress!.replaceAll('%', ''))! / 100, backgroundColor: AppColors.secondary, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.small / 2),
        // Індикатор пагінації (крапочки)
        Row(
          mainAxisAlignment: MainAxisAlignment.start, 
          children: List.generate(courses.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 8.0), 
              width: 8.0,
              height: 8.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _currentPageMy ? AppColors.primary : AppColors.secondary.withAlpha(127),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ... (_buildMyTasks, _buildContentBody, build - без змін)

  // ⭐️ ListView.builder - для ефективного вертикального списку задач ⭐️
  Widget _buildMyTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Мої задачі (ListView)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.small / 2),

        Container(
          height: 250, // Фіксована висота
          padding: const EdgeInsets.all(AppSpacing.medium),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          // Використовуємо ListView.builder для лінивого створення елементів
          child: ListView.builder(
            itemCount: myTasks.length,
            itemBuilder: (context, index) {
              final task = myTasks[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.small / 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder_open, size: 18, color: Colors.orange),
                        const SizedBox(width: AppSpacing.small),
                        Text(task.label, style: const TextStyle(fontSize: 14)), 
                      ],
                    ),
                    Text(task.time, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  // --- КОНТЕНТ В ЗАЛЕЖНОСТІ ВІД ВИБОРУ МЕНЮ ---

  Widget _buildContentBody(int index) {
    switch (index) {
      case 0: // Головна сторінка
        return Consumer<CourseModel>(
          builder: (context, courseModel, child) {
            
            // СТАН ЗАВАНТАЖЕННЯ АБО ПОЧАТКОВИЙ СТАН
            if (courseModel.status == DataStatus.Loading || courseModel.status == DataStatus.Initial) {
              return const Center(child: CircularProgressIndicator());
            }

            // СТАН ПОМИЛКИ
            if (courseModel.status == DataStatus.Error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      'Помилка завантаження даних:\n${courseModel.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    ElevatedButton(
                      onPressed: courseModel.loadCourses, 
                      child: const Text('Спробувати знову'),
                    ),
                  ],
                ),
              );
            }
            
            // СТАН УСПІШНО ЗАВАНТАЖЕНО (DataStatus.Loaded)
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDemoSettings(),
                  const SizedBox(height: AppSpacing.large),
                  
                  // GridView
                  _buildRecommendedCourses(courseModel.recommendedCourses), 
                  const SizedBox(height: AppSpacing.large),
                  
                  // РОЗМІЩЕННЯ 50/50: Row з Expanded
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // БЛОК "МОЇ КУРСИ" (PageView)
                      Expanded(
                        child: _buildMyCoursesSection(courseModel.myCourses), 
                      ),
                      const SizedBox(width: AppSpacing.large),

                      // БЛОК "МОЇ ЗАДАЧІ" (ListView)
                      Expanded(
                        child: _buildMyTasks(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpacing.large),
                ],
              ),
            );
          },
        );
      case 1: // Курси (приклад)
        return const Center(child: Text('Контент екрану "Курси"', style: TextStyle(fontSize: 24)));
      case 2: // Мої курси (приклад)
        return const Center(child: Text('Контент екрану "Мої курси" - детальний перегляд', style: TextStyle(fontSize: 24)));
      default:
        return const Center(child: Text('Помилка: Невідомий екран', style: TextStyle(fontSize: 24)));
    }
  }

  // --- МЕТОД BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Ліва бічна панель (Sidebar)
          Container(
            width: 250,
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Логотип (зверху)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: Row(
                    children: [
                      const Icon(Icons.book, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.small),
                      const Text(
                        'EDUCATION',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Пункти меню
                ..._pageTitles.asMap().entries.map((entry) {
                  return _buildSidebarItem(entry.key, entry.value, _pageIcons[entry.key]);
                }),

                const Spacer(),

                // Профіль користувача (внизу)
                InkWell(
                  onTap: () {
                    // Вихід з системи
                    Navigator.pushReplacementNamed(context, '/auth');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.medium),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text('О', style: TextStyle(color: AppColors.white)),
                        ),
                        const SizedBox(width: AppSpacing.small),
                        Text(
                          _userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
              ],
            ),
          ),

          // Основний контент
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Верхній вітальний рядок та пошук (Header)
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Привіт, $_userName!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text('Хороший день для навчання! 😊', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),

                      // Поле Пошуку
                      SizedBox(
                        width: 250,
                        child: TextField( // Базове поле пошуку
                          controller: _searchController, 
                          decoration: InputDecoration(
                            hintText: 'Пошук курсів',
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: AppSpacing.medium),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Роздільник під хедером
                Container(height: 1, color: Colors.grey.shade300),

                // Контент сторінки
                Expanded(
                  child: _buildContentBody(_selectedSidebarIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}