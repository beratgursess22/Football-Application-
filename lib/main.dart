import 'package:flutter/material.dart';
import 'package:football_app/pages/coachPage/coach_page.dart';
import 'package:football_app/providers/auth_provider.dart';
import 'package:football_app/providers/calender_proivder.dart';
import 'package:football_app/providers/player_provider.dart';
import 'package:football_app/providers/team_provider.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => CalenderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
        routes: {
          '/coach': (context) => const CoachPage(),
          // '/player': (context) => const PlayerPage(),
          // '/parent': (context) => const ParentPage(),
        },
      ),
    );
  }
}
