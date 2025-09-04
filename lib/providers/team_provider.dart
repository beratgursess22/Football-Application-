import 'dart:async';
import 'package:flutter/material.dart';
import 'package:football_app/models/team_model.dart';
import 'package:football_app/service/team_service.dart';

class TeamProvider with ChangeNotifier {
  final TeamService _teamService = TeamService();

  List<TeamModel> _teams = [];
  TeamModel? _team;
  bool _isLoading = false;
  String? _error;

  List<TeamModel> get teams => _teams;
  TeamModel? get team => _team;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> addTeam(String? token, String name) async {
    if (token == null || token.isEmpty || name.trim().isEmpty) return false;

    _isLoading = true;
    scheduleMicrotask(() => notifyListeners());

    try {
      await _teamService.addTeam(token, name.trim());
      return true;
    } catch (e) {
      debugPrint('TeamProvider addTeam error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTeam(String? token, String name) async {
    if (token == null || token.isEmpty || name.trim().isEmpty) return false;

    _isLoading = true;
    scheduleMicrotask(() => notifyListeners());

    try {
      await _teamService.deleteTeam(token, name.trim());
      return true;
    } catch (e) {
      debugPrint('TeamProvider deleteTeam error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadTeams(String? token) async {
    if (token == null || token.isEmpty) return false;

    _isLoading = true;
    _error = null;
    // İlk notify'ı ertele:
    scheduleMicrotask(() => notifyListeners());

    try {
      final list = await _teamService.getTeams(token);
      _teams = list;
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('TeamProvider loadTeams error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // İstersen tamamen kaldır; state yönetimini by-pass ediyor.
  Future<List<TeamModel>> getTeams(String? token) {
    if (token == null || token.isEmpty) return Future.value(const []);
    return _teamService.getTeams(token);
  }

  Future<TeamModel?> loadTeamById(String? token, int id) async {
    if (token == null || token.isEmpty || id <= 0) return null;

    _isLoading = true;
    _error = null;
    scheduleMicrotask(() => notifyListeners());

    try {
      final t = await _teamService.getTeamById(token, id);
      _team = t;
      return t;
    } catch (e) {
      _error = e.toString();
      debugPrint('TeamProvider loadTeamById error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
