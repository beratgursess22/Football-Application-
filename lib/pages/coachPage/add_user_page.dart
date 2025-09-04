import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:football_app/pages/coachPage/coach_page.dart';
import 'package:provider/provider.dart';
import 'package:football_app/providers/auth_provider.dart';
import 'package:football_app/service/auth_service.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _cName = TextEditingController();
  final _cPassword = TextEditingController();
  String _role = 'player';
  bool _saving = false;

  static const _grad1 = Color(0xFF7B5CC9);
  static const _grad2 = Color(0xFFBF7BDF);

  @override
  void dispose() {
    _cName.dispose();
    _cPassword.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.92),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _grad1, width: 1.2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final token = context.read<AuthProvider>().token;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Kullanıcı Oluştur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CoachPage()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_grad1, _grad2],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // İç kart (form alanları için beyaz arka plan)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.60),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _cName,
                                      decoration: _dec('Kullanıcı Adı'),
                                      validator: (v) => (v == null || v.trim().isEmpty)
                                          ? 'Zorunlu'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _cPassword,
                                      decoration: _dec('Şifre'),
                                      obscureText: true,
                                      validator: (v) => (v == null || v.trim().isEmpty)
                                          ? 'Zorunlu'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: _role,
                                      decoration: _dec('Rol'),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'player', child: Text('Oyuncu')),
                                        DropdownMenuItem(
                                            value: 'coach', child: Text('Antrenör')),
                                        DropdownMenuItem(
                                            value: 'parent', child: Text('Veli')),
                                      ],
                                      onChanged: (v) => setState(() => _role = v!),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: _grad1,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: _saving
                                            ? null
                                            : () async {
                                                if (token == null) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Önce giriş yapmalısın.'),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                if (!_formKey.currentState!.validate()) {
                                                  return;
                                                }

                                                setState(() => _saving = true);
                                                try {
                                                  final id = await AuthService().register(
                                                    name: _cName.text,
                                                    password: _cPassword.text,
                                                  );
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Kullanıcı oluşturuldu (id: $id)'),
                                                    ),
                                                  );
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => const CoachPage(),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Hata: $e')),
                                                  );
                                                } finally {
                                                  if (mounted) setState(() => _saving = false);
                                                }
                                              },
                                        child: _saving
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(strokeWidth: 2.6),
                                              )
                                            : const Text('Kaydet'),
                                      ),
                                    ),
                                  ],
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
            ),
          ),
        ],
      ),
    );
  }
}
