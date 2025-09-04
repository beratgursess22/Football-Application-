// lib/pages/coachPage/coach_page.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:football_app/pages/coachPage/add_player_page.dart';
import 'package:football_app/pages/coachPage/add_user_page.dart';
import 'package:football_app/pages/coachPage/add_teams_page.dart';
import 'package:football_app/pages/coachPage/assing_to_team_page.dart';
import 'package:football_app/pages/coachPage/calender_page.dart';
import 'package:football_app/pages/coachPage/ui_helper/helper_for_coach_page.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});
  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  int _selectedIndex = 0;
  void _onItemTapped(int i) => setState(() => _selectedIndex = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Coach Page'),
      ),
      body: Stack(
        children: const [
          GradientBackground(),
          Positioned(top: -120, right: -80, child: Blob(size: 260, opacity: .16)),
          Positioned(bottom: -140, left: -100, child: Blob(size: 320, opacity: .12)),
          SafeArea(child: CoachHomePage()),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9D4EDD), Color(0xFFB5179E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Ana Sayfa'),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Ayarlar'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CoachHomePage extends StatelessWidget {
  const CoachHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <DashItem>[
      DashItem(icon: Icons.search_rounded, title: "Oyuncu Profilleri", onTap: () {}),
      DashItem(
        icon: Icons.person_add_alt_1_rounded,
        title: "Oyuncu Ekle",
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PlayerEditorPage())),
      ),
      DashItem(icon: Icons.fitness_center_rounded, title: "Takım İçin Antrenman", onTap: () {}),
      DashItem(
        icon: Icons.create_rounded,
        title: "Takım Oyuncularını Göster",
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AssignToTeamPage())),
      ),
      DashItem(icon: Icons.bar_chart_rounded, title: "Performans Analizi", onTap: () {}),
      DashItem(
        icon: Icons.add_circle_outline_rounded,
        title: "Takım Oluştur",
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AddTeamPage())),
      ),
      DashItem(
        icon: Icons.person_add_rounded,
        title: "Oyuncu Girişi Oluştur",
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CreateUserPage())),
      ),
      DashItem(icon: Icons.bar_chart_rounded, title: "Performans Analizi", onTap: () {}),
      DashItem(
        icon: Icons.calendar_month,
        title: "Takvim",
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CalendarPageSimple())),
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final crossCount = w >= 1100 ? 4 : w >= 800 ? 3 : 2;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.05,
            ),
            itemCount: actions.length,
            itemBuilder: (_, i) => GlassActionCard(item: actions[i]),
          ),
        );
      },
    );
  }
}
