import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:football_app/providers/auth_provider.dart';
import 'package:football_app/controllers/player_controller.dart';
import 'package:football_app/pages/coachPage/coach_page.dart';
import 'package:football_app/providers/team_provider.dart';
import 'package:football_app/models/team_model.dart';

enum CrudMode { create, update, delete }

class PlayerEditorPage extends StatefulWidget {
  const PlayerEditorPage({super.key});

  @override
  State<PlayerEditorPage> createState() => _PlayerEditorPageState();
}

class _PlayerEditorPageState extends State<PlayerEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final PlayerController _controller = PlayerController();

  final TextEditingController _jerseyCtrl = TextEditingController();
  bool _busy = false;
  CrudMode _mode = CrudMode.create;

  bool _loadingTeams = false;
  int? _selectedTeamId;

  @override
  void initState() {
    super.initState();
    _bootstrapTeams();
  }

  Future<void> _bootstrapTeams() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) return;
    setState(() => _loadingTeams = true);
    try {
      await context.read<TeamProvider>().loadTeams(token);
      final teams = context.read<TeamProvider>().teams;
      if (teams.isNotEmpty) {
        final existing = _controller.teamId;
        setState(() {
          _selectedTeamId = existing ?? teams.first.id;
        });
        _controller.setTeamId(_selectedTeamId!);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Takım yükleme hatası: $e')));
    } finally {
      if (mounted) setState(() => _loadingTeams = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _jerseyCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );

  Future<void> _loadPlayer(String token) async {
    final jersey = int.tryParse(_jerseyCtrl.text);
    if (jersey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir forma numarası gir')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await _controller.loadByJersey(token, jersey);
      final teamProv = context.read<TeamProvider>();
      if (teamProv.teams.isEmpty) {
        await _bootstrapTeams();
      }
      final tid = _controller.teamId;
      if (tid != null) {
        final exists = context.read<TeamProvider>().teams.any(
          (t) => t.id == tid,
        );
        setState(() => _selectedTeamId = exists ? tid : null);
        if (exists) _controller.setTeamId(tid);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oyuncu yüklendi (forma no: $jersey)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Yükleme hatası: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit(String token) async {
    if (_mode != CrudMode.delete && !_formKey.currentState!.validate()) return;

    if (_mode != CrudMode.delete && _selectedTeamId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir takım seçin.')));
      return;
    }
    if (_selectedTeamId != null) _controller.setTeamId(_selectedTeamId!);

    setState(() => _busy = true);
    try {
      if (_mode == CrudMode.create) {
        final newId = await _controller.submit(token);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Oyuncu eklendi (id: $newId)')));
        _controller.clear();
      } else if (_mode == CrudMode.update) {
        final jersey = int.tryParse(_jerseyCtrl.text);
        if (jersey == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Geçerli bir forma numarası gir')),
          );
          return;
        }
        await _controller.updateByJersey(token, jersey);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oyuncu güncellendi (forma no: $jersey)')),
        );
      } else {
        final jersey = int.tryParse(_jerseyCtrl.text);
        if (jersey == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Geçerli bir forma numarası gir')),
          );
          return;
        }
        final ok = await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Silme Onayı'),
                content: Text(
                  'Bu oyuncuyu silmek istediğine emin misin? (forma no: $jersey)',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Vazgeç'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Sil'),
                  ),
                ],
              ),
        );
        if (ok != true) return;
        await _controller.deleteByJersey(token, jersey);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oyuncu silindi (forma no: $jersey)')),
        );
        _controller.clear();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = context.read<AuthProvider>().token;
    final teamProv = context.watch<TeamProvider>();
    final teams = teamProv.teams;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => CoachPage()),
            );
          },
        ),
        title: const Text('Coach Page'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ---- MOD SEÇİMİ
              SegmentedButton<CrudMode>(
                segments: const [
                  ButtonSegment(
                    value: CrudMode.create,
                    label: Text('Ekle'),
                    icon: Icon(Icons.add),
                  ),
                  ButtonSegment(
                    value: CrudMode.update,
                    label: Text('Güncelle'),
                    icon: Icon(Icons.edit),
                  ),
                  ButtonSegment(
                    value: CrudMode.delete,
                    label: Text('Sil'),
                    icon: Icon(Icons.delete),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged:
                    (s) => setState(() {
                      _mode = s.first;
                    }),
              ),
              const SizedBox(height: 16),

              // ---- Forma No + YÜKLE (Güncelle/Sil için)
              if (_mode != CrudMode.create) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _jerseyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _dec('Forma No'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed:
                          _busy || token == null
                              ? null
                              : () => _loadPlayer(token),
                      icon: const Icon(Icons.download),
                      label:
                          _busy
                              ? const Text('Yükleniyor...')
                              : const Text('Getir'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // ---- FORM
              AbsorbPointer(
                absorbing: _mode == CrudMode.delete,
                child: Opacity(
                  opacity: _mode == CrudMode.delete ? 0.6 : 1,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _controller.name,
                          decoration: _dec('Ad'),
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Zorunlu'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _controller.surname,
                          decoration: _dec('Soyad'),
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Zorunlu'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _controller.position,
                          decoration: _dec('Pozisyon'),
                          items: const [
                            DropdownMenuItem(
                              value: 'Kaleci',
                              child: Text('Kaleci'),
                            ),
                            DropdownMenuItem(
                              value: 'Defans',
                              child: Text('Defans'),
                            ),
                            DropdownMenuItem(
                              value: 'Orta Saha',
                              child: Text('Orta Saha'),
                            ),
                            DropdownMenuItem(
                              value: 'Forvet',
                              child: Text('Forvet'),
                            ),
                          ],
                          onChanged: (v) => _controller.setPosition(v!),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _controller.dominant_foot,
                          decoration: _dec('Baskın Ayak'),
                          items: const [
                            DropdownMenuItem(
                              value: 'right',
                              child: Text('Sağ'),
                            ),
                            DropdownMenuItem(value: 'left', child: Text('Sol')),
                            DropdownMenuItem(value: 'both', child: Text('İki')),
                          ],
                          onChanged: (v) => _controller.setDominantFoot(v!),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _controller.height,
                                keyboardType: TextInputType.number,
                                decoration: _dec('Boy (cm)'),
                                validator:
                                    (v) =>
                                        int.tryParse(v ?? '') == null
                                            ? 'Sayı gir'
                                            : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _controller.weight,
                                keyboardType: TextInputType.number,
                                decoration: _dec('Kilo (kg)'),
                                validator:
                                    (v) =>
                                        int.tryParse(v ?? '') == null
                                            ? 'Sayı gir'
                                            : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _controller.phone,
                          keyboardType: TextInputType.phone,
                          decoration: _dec('Telefon'),
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Zorunlu'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _controller.jersey_number,
                          keyboardType: TextInputType.number,
                          decoration: _dec('Forma No'),
                          validator:
                              (v) =>
                                  int.tryParse(v ?? '') == null
                                      ? 'Sayı gir'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        _loadingTeams
                            ? _TeamDropdownSkeleton()
                            : DropdownButtonFormField<int>(
                              value: _selectedTeamId,
                              decoration: _dec('Takım Seç'),
                              items:
                                  teams
                                      .map(
                                        (TeamModel t) => DropdownMenuItem<int>(
                                          value: t.id,
                                          child: Text(t.name),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (_mode == CrudMode.delete)
                                      ? null
                                      : (v) {
                                        if (v == null) return;
                                        setState(() => _selectedTeamId = v);
                                        _controller.setTeamId(v);
                                      },
                              validator:
                                  (v) =>
                                      (_mode == CrudMode.delete)
                                          ? null
                                          : (v == null ? 'Zorunlu' : null),
                            ),

                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _controller.medical_notes,
                          maxLines: 2,
                          decoration: _dec('Medikal Notlar (opsiyonel)'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _controller.avatar_url,
                          decoration: _dec('Avatar URL (opsiyonel)'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _controller.status,
                          decoration: _dec('Durum'),
                          items: const [
                            DropdownMenuItem(
                              value: 'active',
                              child: Text('Aktif'),
                            ),
                            DropdownMenuItem(
                              value: 'inactive',
                              child: Text('Pasif'),
                            ),
                          ],
                          onChanged: (v) => _controller.setStatus(v!),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _busy || token == null ? null : () => _submit(token),
                  child:
                      _busy
                          ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: CircularProgressIndicator(),
                          )
                          : Text(
                            _mode == CrudMode.create
                                ? 'Kaydet'
                                : _mode == CrudMode.update
                                ? 'Güncelle'
                                : 'Sil',
                          ),
                ),
              ),
              const SizedBox(height: 8),
              if (token == null)
                const Text(
                  'Önce giriş yapmalısın.',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamDropdownSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.6),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
