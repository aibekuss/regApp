// home_page.dart
//
// Home screen shown after a successful login. Profile header with avatar +
// gradient ring, glass info cards, and a gradient logout button — matching
// the new design system used on the login/register screens.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'main.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> user;

  const HomePage({super.key, required this.user});

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final fullName = user['full_name'] ?? 'Пайдаланушы';

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.background)),
          Positioned(
            top: -80,
            right: -70,
            child: _blob(230, AppColors.primary.withValues(alpha: 0.35)),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: _blob(240, AppColors.accent.withValues(alpha: 0.25)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryButton,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Text(
                          _initials(fullName),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Қош келдіңіз!",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.55),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fullName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _InfoCard(
                          icon: Icons.badge_outlined,
                          label: 'Аты-жөні',
                          value: user['full_name']?.toString() ?? '—',
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        _InfoCard(
                          icon: Icons.cake_outlined,
                          label: 'Жасы',
                          value: user['age']?.toString() ?? '—',
                          color: const Color(0xFFB06CFF),
                        ),
                        const SizedBox(height: 12),
                        _InfoCard(
                          icon: Icons.phone_outlined,
                          label: 'Телефон',
                          value: user['phone']?.toString() ?? '—',
                          color: AppColors.accent,
                        ),
                        const SizedBox(height: 12),
                        _InfoCard(
                          icon: Icons.alternate_email_rounded,
                          label: 'Электронды почта',
                          value: user['email']?.toString() ?? '—',
                          color: const Color(0xFFFFB25C),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 54,
                          child: Material(
                            color: AppColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _logout(context),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    "Шығу",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}