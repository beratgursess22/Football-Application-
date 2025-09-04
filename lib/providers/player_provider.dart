import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:football_app/models/player_model.dart';
import 'package:football_app/service/player_service.dart';

class PlayerProvider with ChangeNotifier {
  final PlayerService _playerService = PlayerService();
  bool _isloading = false;
  int? _lastinsertid;
  Map<String, dynamic>? _currentPlayer;
  final Map<int, List<PlayerModel>> _teamPlayersCache = {};

  bool get isloading => _isloading;
  int? get lastinsertid => _lastinsertid;
  Map<String, dynamic>? get currentPlayer => _currentPlayer;
  Map<int, List<PlayerModel>> get teamPlayerCache => _teamPlayersCache;

  Future<bool> addPlayer(String token, Map<String, dynamic> payload) async {
    _isloading = true;
    _lastinsertid = null;
    notifyListeners();
    try {
      final id = await _playerService.addPlayer(token, payload);
      _lastinsertid = id;
      notifyListeners();
      return true;
    } catch (e) {
      throw Exception('kullanıcı eklenmedi: {$e}');
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePlayer(String token, int jerseyNumber) async {
    _isloading = true;
    notifyListeners();
    try {
      await _playerService.deletePlayer(token, jerseyNumber);
      return true;
    } catch (e) {
      throw Exception('Oyuncu silinemedi $e');
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePlayer(
    String token,
    int jerseyNumber,
    Map<String, dynamic> paylaod,
  ) async {
    _isloading = true;
    notifyListeners();
    try {
      await _playerService.updatePlayer(token, jerseyNumber, paylaod);
      return true;
    } catch (e) {
      throw Exception("oyuncu güncellenemedi $e");
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<bool> getPlayer(String token, int jerseyNumber) async {
    _isloading = true;
    _currentPlayer = null;
    notifyListeners();
    try {
      final player = await _playerService.getPlayer(token, jerseyNumber);
      _currentPlayer = player;
      return true;
    } catch (e) {
      throw Exception("oyuncular listelenemedi $e");
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<List<PlayerModel>> getByTeam(String token, int teamId) async {
    _isloading = true;
    notifyListeners();
    try {
      final list = await _playerService.getByTeam(token, teamId);
      _teamPlayersCache[teamId] = list;
      return list;
    } catch (e) {
      debugPrint('PlayerProvider getByTeam error: $e');
      rethrow;
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }
}
