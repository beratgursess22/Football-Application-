
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:football_app/controllers/team_controller.dart';
import 'package:football_app/pages/coachPage/coach_page.dart';
import 'package:provider/provider.dart';
import 'package:football_app/providers/auth_provider.dart';
import 'package:football_app/providers/team_provider.dart';

class AddTeamPage extends StatefulWidget {
  const AddTeamPage({super.key});

  @override
  State<AddTeamPage> createState() => _AddTeamPageState();
}

class _AddTeamPageState extends State<AddTeamPage>
    with SingleTickerProviderStateMixin {
  final _formKeyAdd = GlobalKey<FormState>();
  final _formKeyDelete = GlobalKey<FormState>();

  final _addCtrl = TeamController();
  final _deleteCtrl = TextEditingController();

  bool _savingAdd = false;
  bool _savingDelete = false;

  late final AnimationController _anim;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeIn = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim.forward();
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    _deleteCtrl.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _submitAdd() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return _toast('Oturum bulunamadı.');
    if (!_formKeyAdd.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _savingAdd = true);
    try {
      final ok = await _addCtrl.submit(context, token);
      if (!mounted) return;
      if (ok) {
        _toast('Takım eklendi: ${_addCtrl.name.text.trim()}');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CoachPage()));
      } else {
        _toast('Ekleme başarısız.');
      }
    } finally {
      if (mounted) setState(() => _savingAdd = false);
    }
  }

  Future<void> _submitDelete() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return _toast('Oturum bulunamadı.');
    if (!_formKeyDelete.currentState!.validate()) return;

    final name = _deleteCtrl.text.trim();
    final okConfirm = await _confirmDelete(name);
    if (!okConfirm) return;

    FocusScope.of(context).unfocus();
    setState(() => _savingDelete = true);
    try {
      final ok = await context.read<TeamProvider>().deleteTeam(token, name);
      if (!mounted) return;
      if (ok) {
        _toast('Silindi: $name');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CoachPage()));
      } else {
        _toast('Silme başarısız.');
      }
    } finally {
      if (mounted) setState(() => _savingDelete = false);
    }
  }

  Future<bool> _confirmDelete(String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Emin misin?'),
            content: Text('“$name” takımını silmek üzeresin.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
              FilledButton.icon(
                onPressed: () => Navigator.pop(ctx, true),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Sil'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CoachPage()));
          },
        ),
        title: const Text('Coach Page'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Gradient arka plan
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9D4EDD), Color(0xFFB5179E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // dekoratif “top wave”
          Positioned(
            top: -120,
            right: -80,
            child: _Blob(size: 240, opacity: 0.15),
          ),
          Positioned(
            bottom: -140,
            left: -100,
            child: _Blob(size: 300, opacity: 0.10),
          ),

          // içerik
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 900;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Takımlar',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Yeni takım oluştur, ya da mevcut bir takımı sil.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 24),

                        // responsive grid
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: wide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _glassCard(child: _buildAddCard(theme))),
                                    const SizedBox(width: 20),
                                    Expanded(child: _glassCard(child: _buildDeleteCard(theme))),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _glassCard(child: _buildAddCard(theme)),
                                    const SizedBox(height: 20),
                                    _glassCard(child: _buildDeleteCard(theme)),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------- UI Parçaları --------

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAddCard(ThemeData theme) {
    return Form(
      key: _formKeyAdd,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHeader(
            title: 'Yeni Takım Kaydı',
            subtitle: 'Kadro yönetimine hızlı başlangıç.',
            icon: Icons.military_tech_rounded,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          _fTextField(
            controller: _addCtrl.name,
            label: 'Takım Adı',
            hint: 'Örn: U14 Laleli',
            prefix: Icons.group_add_rounded,
            validator: (v) {
              final t = v?.trim() ?? '';
              if (t.isEmpty) return 'Takım adı zorunlu';
              if (t.length < 3) return 'En az 3 karakter';
              if (t.length > 100) return 'En fazla 100 karakter';
              return null;
            },
            onSubmitted: (_) => _submitAdd(),
          ),
          const SizedBox(height: 14),
          _primaryAction(
            onPressed: _savingAdd ? null : _submitAdd,
            icon: _savingAdd ? const _MiniSpinner() : const Icon(Icons.save_alt_rounded),
            label: _savingAdd ? 'Kaydediliyor...' : 'Kaydet',
          ),
          const SizedBox(height: 8),
          _ghostAction(
            onPressed: _savingAdd ? null : () => Navigator.pop(context),
            icon: Icons.arrow_back_rounded,
            label: 'Geri',
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteCard(ThemeData theme) {
    return Form(
      key: _formKeyDelete,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardHeader(
            title: 'Takım Sil',
            subtitle: 'Dikkat: Bu işlem geri alınamaz.',
            icon: Icons.delete_sweep_rounded,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          _fTextField(
            controller: _deleteCtrl,
            label: 'Takım Adı',
            hint: 'Silinecek takım',
            prefix: Icons.delete_outline_rounded,
            validator: (v) {
              final t = v?.trim() ?? '';
              if (t.isEmpty) return 'Takım adı zorunlu';
              if (t.length < 3) return 'En az 3 karakter';
              return null;
            },
            onSubmitted: (_) => _submitDelete(),
          ),
          const SizedBox(height: 14),
          _destructiveAction(
            onPressed: _savingDelete ? null : _submitDelete,
            icon: _savingDelete ? const _MiniSpinner() : const Icon(Icons.delete_forever_rounded),
            label: _savingDelete ? 'Siliniyor...' : 'Sil',
          ),
          const SizedBox(height: 8),
          _ghostAction(
            onPressed: _savingDelete ? null : () => Navigator.pop(context),
            icon: Icons.arrow_back_rounded,
            label: 'Geri',
          ),
        ],
      ),
    );
  }

  Widget _cardHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.18),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.95),
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  )),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.75),
                    fontSize: 13,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefix,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefix, color: Colors.white),
        hintStyle: TextStyle(color: Colors.white.withOpacity(.7)),
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(.12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(.28)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white, width: 1.4),
        ),
        errorStyle: const TextStyle(color: Colors.yellowAccent),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _primaryAction({VoidCallback? onPressed, required Widget icon, required String label}) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF6C63FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _destructiveAction({VoidCallback? onPressed, required Widget icon, required String label}) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(label),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.white.withOpacity(.16),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          side: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _ghostAction({VoidCallback? onPressed, required IconData icon, required String label}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _MiniSpinner extends StatelessWidget {
  const _MiniSpinner();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2));
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.opacity});
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
