import 'package:flutter/material.dart';
import 'package:football_app/pages/coachPage/coach_page.dart';
import 'package:provider/provider.dart';

import 'package:football_app/providers/auth_provider.dart';
import 'package:football_app/controllers/player_controller.dart';

import 'package:football_app/providers/team_provider.dart'; // ← #1: takım provider'ının import'u
import 'package:football_app/models/team_model.dart';       // ← #2: TeamModel (id, name) varsayıldı
import 'package:football_app/models/player_model.dart';

class AssignToTeamPage extends StatefulWidget {
  const AssignToTeamPage({super.key});

  @override
  State<AssignToTeamPage> createState() => _AssignToTeamPageState();
}

class _AssignToTeamPageState extends State<AssignToTeamPage> {
  final PlayerController _playerCtrl = PlayerController();

  bool _loadingTeams = false;
  bool _loadingPlayers = false;
  String? _error;

  int? _selectedTeamId;
  List<PlayerModel> _players = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadTeams();
    // Varsayılan olarak ilk takımı seç ve oyuncularını getir
    final teams = context.read<TeamProvider>().teams; // ← #3: TeamProvider.teams varsayıldı
    if (teams.isNotEmpty) {
      setState(() => _selectedTeamId = teams.first.id);
      await _loadPlayers(teams.first.id);
    }
  }

  Future<void> _loadTeams() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      setState(() => _error = 'Token bulunamadı (AuthProvider.token null).');
      return;
    }

    setState(() {
      _loadingTeams = true;
      _error = null;
    });

    try {
      await context.read<TeamProvider>().loadTeams(token);
    } catch (e) {
      setState(() => _error = 'Takımlar yüklenemedi: $e');
    } finally {
      setState(() => _loadingTeams = false);
    }
  }

  Future<void> _loadPlayers(int teamId) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      setState(() => _error = 'Token bulunamadı (AuthProvider.token null).');
      return;
    }

    setState(() {
      _loadingPlayers = true;
      _error = null;
    });

    try {
      final list = await _playerCtrl.getByTeam(token, teamId);
      setState(() => _players = list);
    } catch (e) {
      setState(() => _error = 'Oyuncular getirilemedi: $e');
    } finally {
      setState(() => _loadingPlayers = false);
    }
  }

  @override
  void dispose() {
    _playerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Assign to Team Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _loadingTeams
                      ? const _ShimmerBox(height: 56)
                      : DropdownButtonFormField<int>(
                          value: _selectedTeamId,
                          items: teams
                              .map((TeamModel t) => DropdownMenuItem<int>(
                                    value: t.id,
                                    child: Text(t.name),
                                  ))
                              .toList(),
                          decoration: const InputDecoration(
                            labelText: 'Takım Seç',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) async {
                            if (v == null) return;
                            setState(() => _selectedTeamId = v);
                            await _loadPlayers(v);
                          },
                        ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: (_selectedTeamId == null || _loadingPlayers)
                      ? null
                      : () => _loadPlayers(_selectedTeamId!),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yenile'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(.3)),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // OYUNCU LİSTESİ
            Expanded(
              child: _loadingPlayers
                  ? const _PlayerListSkeleton()
                  : _players.isEmpty
                      ? const Center(
                          child: Text('Bu takım için kayıtlı oyuncu yok.'),
                        )
                      : ListView.separated(
                          itemCount: _players.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, thickness: .5),
                          itemBuilder: (context, index) {
                            final p = _players[index];
                            return _PlayerTile(p: p);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------- UI yardımcıları ---------

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({required this.p});
  final PlayerModel p;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = (p.avatarUrl?.isNotEmpty ?? false) ? p.avatarUrl : null;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null ? const Icon(Icons.person) : null,
      ),
      title: Text('${p.name} ${p.surname}'.trim()),
      subtitle: Text('${p.position ?? '-'}  •  #${p.jerseyNumber ?? '-'}'),
      trailing: Text(
        (p.status ?? 'active').toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: (p.status == 'injured')
              ? Colors.orange
              : (p.status == 'inactive')
                  ? Colors.grey
                  : Colors.green,
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({this.height = 40});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(.6),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _PlayerListSkeleton extends StatelessWidget {
  const _PlayerListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (_, __) {
        return Row(
          children: [
            const _ShimmerBox(height: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: const [
                  _ShimmerBox(height: 16),
                  SizedBox(height: 8),
                  _ShimmerBox(height: 14),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
