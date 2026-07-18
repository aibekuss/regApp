// register_page.dart
//
// Registration screen matching the new glassmorphism design system:
// blurred glass card, gradient button, password visibility toggle.
// Client-side validation is preserved exactly as before.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        _showMessage(result["message"] ?? "Тіркеу сәтті аяқталды!",
            isSuccess: true);
        Navigator.pop(context);
      } else {
        _showMessage(result["message"] ?? "Тіркеу сәтсіз аяқталды.");
      }
    } catch (error) {
      _showMessage("Сервермен байланыс орнатылмады.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  InputDecoration _decoration({
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(gradient: AppColors.background)),
          Positioned(
            top: -90,
            right: -60,
            child: _blob(230,
                AppColors.accent.withOpacity(0.30)), // withOpacity қолданылды
          ),
          Positioned(
            bottom: -110,
            left: -70,
            child: _blob(260,
                AppColors.primary.withOpacity(0.40)), // withOpacity қолданылды
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.06), // withOpacity қолданылды
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: Colors.white
                                      .withOpacity(0.12)), // withOpacity
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryButton,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.5), // withOpacity
                                          blurRadius: 24,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      color: Colors.white,
                                      size: 34,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  const Text(
                                    "Тіркелу",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Жаңа аккаунт жасау үшін деректеріңізді енгізіңіз",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white
                                          .withOpacity(0.6), // withOpacity
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // АТЫ
                                  TextFormField(
                                    controller: _firstNameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _decoration(
                                      icon: Icons.person_outline_rounded,
                                      hint: "Аты",
                                    ),
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty)
                                            ? "Аты міндетті."
                                            : null,
                                  ),
                                  const SizedBox(height: 14),

                                  // ТЕГІ
                                  TextFormField(
                                    controller: _lastNameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _decoration(
                                      icon: Icons.people_outline_rounded,
                                      hint: "Тегі",
                                    ),
                                    validator: (value) =>
                                        (value == null || value.trim().isEmpty)
                                            ? "Тегі міндетті."
                                            : null,
                                  ),
                                  const SizedBox(height: 14),

                                  // ЖАСЫ
                                  TextFormField(
                                    controller: _ageController,
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.number,
                                    decoration: _decoration(
                                      icon: Icons.cake_outlined,
                                      hint: "Жасы",
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty)
                                        return "Жас міндетті.";
                                      if (int.tryParse(value.trim()) == null)
                                        return "Жас сан форматта болуы керек.";
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),

                                  // ТЕЛЕФОН
                                  TextFormField(
                                    controller: _phoneController,
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.phone,
                                    decoration: _decoration(
                                      icon: Icons.phone_outlined,
                                      hint: "Телефон нөмері",
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty)
                                        return "Телефон нөмері міндетті.";
                                      if (!_phoneRegex.hasMatch(value.trim()))
                                        return "Қате телефон форматы.";
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),

                                  // ПОШТА
                                  TextFormField(
                                    controller: _emailController,
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: _decoration(
                                      icon: Icons.alternate_email_rounded,
                                      hint: "Электронды почта",
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty)
                                        return "Почта міндетті.";
                                      if (!_emailRegex.hasMatch(value.trim()))
                                        return "Қате почта форматы.";
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),

                                  // ҚҰПИЯ СӨЗ
                                  TextFormField(
                                    controller: _passwordController,
                                    style: const TextStyle(color: Colors.white),
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                          Icons.lock_outline_rounded),
                                      hintText: "Құпия сөз",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: Colors.white38,
                                        ),
                                        onPressed: () => setState(() =>
                                            _obscurePassword =
                                                !_obscurePassword),
                                      ),
                                    ),
                                    validator: (value) =>
                                        (value == null || value.isEmpty)
                                            ? "Құпия сөз міндетті."
                                            : null,
                                  ),
                                  const SizedBox(height: 14),

                                  // ҚҰПИЯ СӨЗДІ РАСТАУ
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    style: const TextStyle(color: Colors.white),
                                    obscureText: _obscureConfirmPassword,
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          const Icon(Icons.lock_reset_rounded),
                                      hintText: "Құпия сөзді қайталаңыз",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: Colors.white38,
                                        ),
                                        onPressed: () => setState(() =>
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return "Құпия сөзді растаңыз.";
                                      if (value != _passwordController.text)
                                        return "Құпия сөздер сәйкес келмейді.";
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 26),

                                  _GradientButton(
                                    label: "Тіркелу",
                                    isLoading: _isLoading,
                                    onPressed: _handleRegister,
                                  ),
                                  const SizedBox(height: 18),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Аккаунтыңыз бар ма?",
                                        style: TextStyle(
                                            color: Colors.white.withOpacity(
                                                0.6)), // withOpacity
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: TextButton.styleFrom(
                                            foregroundColor: AppColors.accent),
                                        child: const Text(
                                          "Кіру",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: AppColors.primaryButton,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.45), // withOpacity
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
