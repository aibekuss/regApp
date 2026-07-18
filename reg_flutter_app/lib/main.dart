import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart'; // Премиум шрифт пакеті

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        // Бүкіл қолданбаға заманауи Inter шрифтін орнатамыз
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          bodyLarge: GoogleFonts.inter(letterSpacing: -0.4, color: Colors.white),
          bodyMedium: GoogleFonts.inter(letterSpacing: -0.2, color: const Color(0xFF9EA7B6)),
        ),
      ),
      home: const RegisterScreen(),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true; // Парольді жасыру/көрсету күйі

  // 🔥 СЕНІҢ НАҚТЫ СІЛТЕМЕҢ ОСЫ ЖЕРГЕ СӘТТІ ҚОСЫЛДЫ:
  final String googleSheetsApi = 'https://script.google.com/macros/s/AKfycbw0QOUWdJ7ptMbLCG6o2a9Nz1w1ypPdc0TSkfu-Bzqzje6IC85hgsNxlPUe50Y1vBG-ig/exec';

  Future<void> _handleRegister() async {
    final fullName = _nameController.text.trim();
    final age = _ageController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (fullName.isEmpty || age.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      _showDialog('Қате', 'Барлық өрістерді толық толтырыңыз!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(googleSheetsApi),
        headers: {'Content-Type': 'text/plain'},
        body: jsonEncode({
          'fullName': fullName,
          'age': age,
          'phone': phone,
          'email': email,
          'password': password,
          'registeredAt': DateTime.now().toLocal().toString().substring(0, 19),
        }),
      );

      final resData = jsonDecode(response.body);

      if (resData['status'] == 'already_exists') {
        _showDialog('Тіркелу мүмкін емес', resData['message']);
      } else if (resData['status'] == 'success') {
        _showDialog('Керемет!', 'Сіз сәтті тіркелдіңіз. Деректер кестеге енді!');
        _nameController.clear();
        _ageController.clear();
        _phoneController.clear();
        _emailController.clear();
        _passwordController.clear();
      }
    } catch (error) {
      _showDialog('Қателік', 'Сервермен байланыс үзілді.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131A2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.white)),
        content: Text(message, style: GoogleFonts.inter(letterSpacing: -0.3, color: const Color(0xFF9EA7B6))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF007AFF))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 💎 Сәнді REGapp логотипі
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 38, letterSpacing: -1.5),
                    children: const [
                      TextSpan(text: 'REG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                      TextSpan(text: 'app', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w200)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131A2C),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1E2943), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Қатесі толық жөнделді
                    children: [
                      Text('Тіркелу', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.white)),
                      const SizedBox(height: 6),
                      Text('Жалғастыру үшін деректерді енгізіңіз', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF657593), letterSpacing: -0.2)),
                      const SizedBox(height: 24),
                      _buildTextField(_nameController, 'Толық аты-жөніңіз (Full Name)', TextInputType.text),
                      const SizedBox(height: 14),
                      _buildTextField(_ageController, 'Жасыңыз (Age)', TextInputType.number),
                      const SizedBox(height: 14),
                      _buildTextField(_phoneController, 'Телефон нөмірі (Phone)', TextInputType.phone),
                      const SizedBox(height: 14),
                      _buildTextField(_emailController, 'Электронды почта (Email)', TextInputType.emailAddress),
                      const SizedBox(height: 14),
                      // 👁 Көздің суреті бар құпия сөз өрісі
                      _buildTextField(
                        _passwordController, 
                        'Құпия сөз (Password)', 
                        TextInputType.visiblePassword, 
                        obscure: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF526385),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007AFF),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isLoading ? null : _handleRegister,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text('Тіркелу', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType type, {bool obscure = false, Widget? suffixIcon}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15, letterSpacing: -0.2),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF526385), fontSize: 14, letterSpacing: -0.2),
        filled: true,
        fillColor: const Color(0xFF1C263E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF222F4D), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF007AFF), width: 1.5),
        ),
      ),
    );
  }
}