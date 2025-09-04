import 'package:flutter/material.dart';
import 'package:football_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';


class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null || user.role != 'player') {
      return const Scaffold(
        body: Center(
          child: Text("Bu sayfaya erişim yetkiniz yok."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hoş geldin, ${user.name} 👋'),
            const SizedBox(height: 10),
            const Text('Sen bir PLAYER\'sın 🕹️'),
          ],
        ),
      ),
    );
  }
}
