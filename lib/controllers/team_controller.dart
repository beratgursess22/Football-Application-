// lib/controllers/team_controller.dart
import 'package:flutter/widgets.dart';
import 'package:football_app/providers/team_provider.dart';
import 'package:football_app/models/team_model.dart'; // <- ekle

class TeamController {
  final TextEditingController name = TextEditingController();
  final TextEditingController deletename = TextEditingController();
  final TeamProvider _provider = TeamProvider();

  Future<bool> submit(BuildContext context, String token) async {
    try {
      final String finalName = name.text.trim();
      if (finalName.isEmpty) return false;

      final ok = await _provider.addTeam(token, finalName);
      return ok;
    } catch (e) {
      debugPrint('TeamController submit error: $e');
      return false;
    }
  }

  Future<bool> delete(BuildContext context, String token) async {
    try {
      final String finalName = deletename.text.trim();
      if (finalName.isEmpty) return false;

      final ok = await _provider.deleteTeam(token, finalName);
      if (ok) name.clear();
      return ok;
    } catch (e) {
      debugPrint('TeamController delete error: $e');
      return false;
    }
  }

  Future<List<TeamModel>> getTeams(String token) async {
    try {
      final list = await _provider.getTeams(token); // <-- getTeams
      return list;
    } catch (e) {
      debugPrint('TeamController getTeams error: $e');
      return <TeamModel>[];
    }
  }

  Future<bool> refreshTeams(String token) => _provider.loadTeams(token);

  Future<TeamModel?> getTeamById(String token, int id) async {
    try {
      return await _provider.loadTeamById(token, id);
    } catch (e) {
      debugPrint('TeamController getTeamById error: $e');
      return null;
    }
  }

  void dispose() {
    name.dispose();
    deletename.dispose();
  }

  void clears() {
    name.clear();
  }
}
