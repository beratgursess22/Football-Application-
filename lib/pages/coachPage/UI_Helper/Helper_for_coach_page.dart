// lib/pages/coachPage/ui_helper/helper_for_coach_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9D4EDD), Color(0xFFB5179E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class Blob extends StatelessWidget {
  const Blob({super.key, required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Colors.white.withOpacity(opacity), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(.22)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class DashItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  DashItem({required this.icon, required this.title, required this.onTap});
}

class GlassActionCard extends StatelessWidget {
  const GlassActionCard({super.key, required this.item});
  final DashItem item;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 42, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
