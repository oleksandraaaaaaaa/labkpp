// lib/course_form_screen.dart (ПОВНИЙ КОД: Форма створення/редагування з Image Picker)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'models/course.dart';
import 'course_form_model.dart'; 
import 'package:image_picker/image_picker.dart'; // ⭐️ Для вибору зображення ⭐️
import 'dart:io'; // Для роботи з File

class CourseFormScreen extends StatelessWidget {
  // Курс для редагування (або null, якщо створюємо новий)
  final Course? courseToEdit; 
  
  const CourseFormScreen({super.key, this.courseToEdit});

  @override
  Widget build(BuildContext context) {
    // Надаємо доступ до моделі форми тільки для цього екрана
    return ChangeNotifierProvider(
      create: (context) => CourseFormModel(),
      child: _CourseFormView(courseToEdit: courseToEdit),
    );
  }
}

class _CourseFormView extends StatefulWidget {
  final Course? courseToEdit;

  const _CourseFormView({required this.courseToEdit});

  @override
  State<_CourseFormView> createState() => _CourseFormViewState();
}

class _CourseFormViewState extends State<_CourseFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  final ImagePicker _picker = ImagePicker(); // Створення екземпляра Picker

  @override
  void initState() {
    super.initState();
    // Ініціалізація контролерів початковими даними
    _titleController = TextEditingController(text: widget.courseToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.courseToEdit?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ⭐️ МЕТОД: ВИБІР ЗОБРАЖЕННЯ З ГАЛЕРЕЇ ⭐️
  Future<void> _pickImage() async {
    // Дозволяємо вибрати зображення з галереї
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery); 
    if (image != null) {
      // Оновлюємо модель вибраним файлом
      Provider.of<CourseFormModel>(context, listen: false).setSelectedImage(File(image.path));
    }
  }

  // МЕТОД, ЩО СПРАЦЬОВУЄ ПРИ НАТИСКАННІ "ЗБЕРЕГТИ"
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final model = Provider.of<CourseFormModel>(context, listen: false); 
      
      model.saveCourse(
        id: widget.courseToEdit?.id, 
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageFile: model.selectedImage, // ⭐️ Передаємо вибраний файл у модель для завантаження ⭐️
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.courseToEdit != null;
    final String title = isEditing ? 'Редагувати курс' : 'Створити новий курс';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.white,
      ),
      body: Consumer<CourseFormModel>(
        builder: (context, model, child) {
          // Обробка станів
          if (model.status == FormStatus.Success) { 
            // Якщо успішно збережено, повертаємося
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
          }

          if (model.status == FormStatus.Error && model.errorMessage != null) {
            // Відображення помилки
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(model.errorMessage!)),
              );
            });
          }

          final bool isLoading = model.status == FormStatus.Submitting;

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ⭐️ ВІДОБРАЖЕННЯ ТА КНОПКА ВИБОРУ ЗОБРАЖЕННЯ ⭐️
                    if (model.selectedImage != null) 
                      Image.file(model.selectedImage!, height: 150, fit: BoxFit.cover),
                    
                    TextButton.icon(
                      icon: const Icon(Icons.image),
                      label: Text(model.selectedImage == null ? 'Вибрати обкладинку' : 'Змінити обкладинку'),
                      onPressed: isLoading ? null : _pickImage,
                    ),
                    const SizedBox(height: AppSpacing.medium),

                    // Поле Заголовка
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Заголовок курсу'),
                      validator: (value) => (value == null || value.isEmpty) ? 'Введіть заголовок.' : null,
                    ),
                    const SizedBox(height: AppSpacing.medium),

                    // Поле Опису
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Опис курсу'),
                      maxLines: 5,
                      validator: (value) => (value == null || value.isEmpty) ? 'Введіть опис.' : null,
                    ),
                    const SizedBox(height: AppSpacing.xLarge),

                    // Кнопка Збереження
                    ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: AppColors.authPrimary,
                      ),
                      child: isLoading 
                          ? const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2)
                          : Text(isEditing ? 'Зберегти зміни' : 'Створити курс', style: const TextStyle(color: AppColors.white)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}