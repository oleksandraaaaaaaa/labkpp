import 'package:flutter/material.dart';
import 'constants.dart';
import 'home_screen.dart'; 
import 'auth_repository.dart'; 
import 'package:firebase_analytics/firebase_analytics.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

// Оголошення класу стану для екрана авторизації
class _AuthScreenState extends State<AuthScreen> {
  // Створення екземпляра репозиторію для доступу до методів Firebase Auth
  final AuthRepository _authRepository = AuthRepository();
  // Створення глобального ключа для доступу до стану віджету Form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Змінна стану, яка відстежує поточний режим (Вхід або Реєстрація)
  AuthMode _authMode = AuthMode.login; 
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Метод для відображення спливаючого повідомлення
  void _showSnackBar(String message) {
    // Перевірка, чи віджет досі приєднаний до дерева елементів
    if (!mounted) return;
    // Отримання доступу до Scaffold Messenger для відображення SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      // Створення SnackBar з повідомленням.
      SnackBar(content: Text(message)),
    );
  }

  // ЛОГІКА ДІЇ КНОПКИ
  void _onActionButtonPressed() async {
    if (!_formKey.currentState!.validate()) {
      // Якщо валідація не пройшла, завершуємо виконання функції
      return; 
    }
    
    // Встановлення стану завантаження в 'true' для відображення індикатора
    setState(() { _isLoading = true; });
    
    // Отримання тексту з контролера
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    try {
      if (_authMode == AuthMode.login) {
        await _authRepository.signIn(email: email, password: password); 
        // Логування події успішного входу в Firebase Analytics.
        FirebaseAnalytics.instance.logLogin(loginMethod: 'email_password'); 
      } else {
        await _authRepository.signUp(email: email, password: password); 
        FirebaseAnalytics.instance.logSignUp(signUpMethod: 'email_password'); 
      }
      
      if (!mounted) return;
      // Перехід на головний екран
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );

    } catch (e) {
      // Відображення помилки користувачевs
      _showSnackBar(e.toString()); 
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void _setAuthMode(AuthMode mode) {
    // Перевірка, чи новий режим відрізняється від поточного, щоб уникнути зайвих оновлень
    if (mode != _authMode) {
      setState(() {
        _authMode = mode;
      });
      _formKey.currentState?.reset();
    }
  }

  // ВАЛІДАТОРИ
  String? _validateName(String? value) {
    // Перевірка: Якщо ми в режимі Реєстрації І поле порожнє або null
    if (_authMode== AuthMode.register && (value == null || value.isEmpty)) {
      return 'Введіть ім\'я.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    // Перевірка: чи поле порожнє або null
    if (value == null || value.isEmpty) {
      return 'Введіть Email.';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Некоректний формат Email.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введіть пароль.';
    }
    if (value.length < 6) {
      return 'Пароль має бути не менше 6 символів.';
    }
    return null;
  }
  
  String? _validateConfirmPassword(String? value) {
    if (_authMode == AuthMode.register) {
      if (value == null || value.isEmpty) {
        return 'Повторіть пароль.';
      }
      if (value != _passwordController.text) {
        return 'Паролі не збігаються.';
      }
    }
    return null;
  }

  // ПОЛЯ ВВОДУ
  Widget _buildFormFields() {
    final bool isLogin = _authMode == AuthMode.login;

    return Column(
      children: [
        if (!isLogin) ...[
          const Align(alignment: Alignment.centerLeft, child: Text('Ім\'я', style: TextStyle(color: AppColors.navItemColor))),
          const SizedBox(height: AppSpacing.small),
          TextFormField(
            controller: _nameController,
            validator: _validateName,
            decoration: const InputDecoration(filled: true, fillColor: AppColors.white, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFFCED4DA))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.authPrimary)), contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: AppSpacing.medium)),
          ),
          const SizedBox(height: AppSpacing.large),
        ],
        
        const Align(alignment: Alignment.centerLeft, child: Text('Email', style: TextStyle(color: AppColors.navItemColor))),
        const SizedBox(height: AppSpacing.small),
        TextFormField(
          controller: _emailController,
          validator: _validateEmail,
          decoration: const InputDecoration(filled: true, fillColor: AppColors.white, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFFCED4DA))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.authPrimary)), contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: AppSpacing.medium)),
        ),

        const SizedBox(height: AppSpacing.large),

        const Align(alignment: Alignment.centerLeft, child: Text('Пароль', style: TextStyle(color: AppColors.navItemColor))),
        const SizedBox(height: AppSpacing.small),
        TextFormField(
          controller: _passwordController,
          validator: _validatePassword,
          obscureText: true,
          decoration: const InputDecoration(filled: true, fillColor: AppColors.white, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFFCED4DA))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.authPrimary)), suffixIcon: Padding(padding: EdgeInsets.only(right: AppSpacing.medium), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.visibility_off, color: AppColors.navItemColor, size: 20), SizedBox(width: 5), Text('Hide', style: TextStyle(color: AppColors.navItemColor)),],),), contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: AppSpacing.medium)),
        ),

        if (!isLogin) ...[
          const SizedBox(height: AppSpacing.large),
          const Align(alignment: Alignment.centerLeft, child: Text('Повтор пароля', style: TextStyle(color: AppColors.navItemColor))),
          const SizedBox(height: AppSpacing.small),
          TextFormField(
            controller: _confirmPasswordController,
            validator: _validateConfirmPassword,
            obscureText: true,
            decoration: const InputDecoration(filled: true, fillColor: AppColors.white, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFFCED4DA))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.authPrimary)), contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: AppSpacing.medium)),
          ),
        ],
        
        const SizedBox(height: AppSpacing.xLarge),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLogin = _authMode == AuthMode.login;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(AppSpacing.xLarge),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: SingleChildScrollView( 
            child: Form( 
              key: _formKey, 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // TABS: ВХІД / РЕЄСТРАЦІЯ
                  Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.navItemColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _setAuthMode(AuthMode.login),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLogin ? AppColors.authPrimary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Вхід',
                              style: TextStyle(
                                color: isLogin ? AppColors.white : AppColors.navItemColor.withOpacity(0.8),
                                fontWeight: isLogin ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => _setAuthMode(AuthMode.register),
                          child: Container(
                            decoration: BoxDecoration(
                              color: !isLogin ? AppColors.authPrimary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Реєстрація',
                              style: TextStyle(
                                color: !isLogin ? AppColors.white : AppColors.navItemColor.withOpacity(0.8),
                                fontWeight: !isLogin ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xLarge),

                Text(
                  isLogin ? 'Вхід' : 'Реєстрація',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark),
                ),

                const SizedBox(height: AppSpacing.xLarge),
                
                _buildFormFields(),
                
                // Кнопка дії
                ElevatedButton(
                  onPressed: _isLoading ? null : _onActionButtonPressed, 
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: AppColors.authPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                    : Text(
                        isLogin ? 'Ввійти' : 'Зареєструватися',
                        style: const TextStyle(fontSize: 18, color: AppColors.white),
                      ),
                ),

                const SizedBox(height: AppSpacing.xLarge * 2),

                // Логотип
                const Column(
                  children: [
                    Icon(Icons.book, color: AppColors.primary, size: 40),
                    Text(
                      'EDUCATION',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}