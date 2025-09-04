import 'package:flutter/material.dart';
import 'package:football_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFAF3FF), Color(0xFFE0D4FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Giriş Yap",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: authProvider.nameController,
                      decoration: const InputDecoration(
                        labelText: 'Kullanıcı Adı',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: authProvider.passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Şifre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Rol Seç",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      alignment: WrapAlignment.center,
                      children: ['player', 'coach', 'parent'].map((role) {
                        return ChoiceChip(
                          label: Text(
                            role == 'player'
                                ? 'Oyuncu'
                                : role == 'coach'
                                    ? 'Antrenör'
                                    : 'Veli',
                          ),
                          selected: authProvider.selectedRole == role,
                          onSelected: (_) => authProvider.setRole(role),
                          selectedColor: Colors.deepPurpleAccent,
                          labelStyle: TextStyle(
                            color: authProvider.selectedRole == role
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: authProvider.isloading
                            ? null
                            : () async {
                                final success = await authProvider.login();
                                if (success) {
                                  final role = authProvider.user!.role;
                                  if (role == 'coach') {
                                    Navigator.pushNamed(context, '/coach');
                                  } else if (role == 'player') {
                                    Navigator.pushNamed(context, '/player');
                                  } else {
                                    Navigator.pushNamed(context, '/parent');
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Giriş başarısız")),
                                  );
                                }
                              },
                        child: authProvider.isloading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Giriş Yap",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
