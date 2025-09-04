import 'package:flutter/widgets.dart';
import 'package:football_app/models/player_model.dart';
import 'package:football_app/providers/player_provider.dart';

class PlayerController {
  final PlayerProvider _playerProvider = PlayerProvider();

  // Text fields
  final TextEditingController name = TextEditingController();
  final TextEditingController surname = TextEditingController();
  final TextEditingController birth_day = TextEditingController(); // 'YYYY-MM-DD'
  final TextEditingController height = TextEditingController();
  final TextEditingController weight = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController jersey_number = TextEditingController();
  final TextEditingController team_name = TextEditingController(); // sadece gösterim/opsiyonel
  final TextEditingController medical_notes = TextEditingController();
  final TextEditingController avatar_url = TextEditingController();

  // Select fields
  String position = 'Forvet';
  String dominant_foot = 'right';
  String status = 'active';

  int? teamId;
  void setTeamId(int v) => teamId = v;

  void setPosition(String v) => position = v;
  void setDominantFoot(String v) => dominant_foot = v;
  void setStatus(String v) => status = v;

  Future<int> submit(String token) async {
    if (name.text.trim().isEmpty ||
        surname.text.trim().isEmpty ||
        phone.text.trim().isEmpty ||
        position.trim().isEmpty) {
      throw Exception('Zorunlu alanlar boş bırakılamaz');
    }

    if (teamId == null) {
      throw Exception('Takım seçilmedi (team_id null).');
    }

    final h = int.tryParse(height.text);
    final w = int.tryParse(weight.text);
    final j = int.tryParse(jersey_number.text);
    if (h == null || w == null || j == null) {
      throw Exception("Boy/Kilo/Forma No sayısal olmalı.");
    }

    const validFeet = ['right', 'left', 'both'];
    if (!validFeet.contains(dominant_foot)) {
      throw Exception('Baskın ayak seçilenlerden olmalı');
    }

    if (phone.text.trim().length > 20) {
      throw Exception('Telefon numarası 20 karakteri geçemez');
    }

    final bd = birth_day.text.trim();
    final birth = bd.contains('T') ? bd.split('T').first : bd;

    final payload = {
      'name': name.text.trim(),
      'surname': surname.text.trim(),
      'birth_day': DateTime.tryParse(birth) ?? DateTime.now().toIso8601String(),
      'height': h,
      'weight': w,
      'phone': phone.text.trim(),
      'jersey_number': j,
      'medical_notes': medical_notes.text.trim().isEmpty ? null : medical_notes.text.trim(),
      'avatar_url': avatar_url.text.trim().isEmpty ? null : avatar_url.text.trim(),
      'position': position,
      'dominant_foot': dominant_foot,
      'status': status,
      'team_id': teamId, 
    };

    final ok = await _playerProvider.addPlayer(token, payload);
    if (!ok) {
      throw Exception("Kayıt başarısız:");
    }

    final id = _playerProvider.lastinsertid;
    if (id == null) {
      throw Exception("Kayıt başarılı ama id alınamadı");
    }
    return id;
  }

  Future<void> loadByJersey(String token, int jerseyNumber) async {
    final ok = await _playerProvider.getPlayer(token, jerseyNumber);
    if (!ok) throw Exception("Oyuncu bulunamadı");

    final data = _playerProvider.currentPlayer!;

    name.text = data['name'] ?? '';
    surname.text = data['surname'] ?? '';

    final bd = (data['birth_day'] ?? '').toString();
    birth_day.text = bd.contains('T') ? bd.split('T').first : bd;
    height.text = (data['height'] ?? '').toString();
    weight.text = (data['weight'] ?? '').toString();
    phone.text = data['phone'] ?? '';
    jersey_number.text = (data['jersey_number'] ?? '').toString();
    medical_notes.text = data['medical_notes'] ?? '';
    avatar_url.text = data['avatar_url'] ?? '';
    position = data['position'] ?? 'Forvet';
    dominant_foot = data['dominant_foot'] ?? 'right';
    status = data['status'] ?? 'active';
    teamId = data['team_id'];            
    team_name.text = data['team_name'] ?? ''; 
  }

  Future<void> updateByJersey(String token, int jerseyNumber) async {
    final h = int.tryParse(height.text);
    final w = int.tryParse(weight.text);
    final j = int.tryParse(jersey_number.text);
    if (h == null || w == null || j == null) {
      throw Exception("Boy/Kilo/Forma No sayısal olmalı.");
    }

    if (teamId == null) {
      throw Exception('Takım seçilmedi (team_id null).');
    }

    final bd = birth_day.text.trim();
    final birth = bd.contains('T') ? bd.split('T').first : bd;

    final payload = {
      'name': name.text.trim(),
      'surname': surname.text.trim(),
      'birth_day': birth,
      'height': h,
      'weight': w,
      'phone': phone.text.trim(),
      'jersey_number': j,
      'medical_notes': medical_notes.text.trim().isEmpty ? null : medical_notes.text.trim(),
      'avatar_url': avatar_url.text.trim().isEmpty ? null : avatar_url.text.trim(),
      'position': position,
      'dominant_foot': dominant_foot,
      'status': status,
      'team_id': teamId,
    };

    final ok = await _playerProvider.updatePlayer(token, jerseyNumber, payload);
    if (!ok) throw Exception("Güncelleme başarısız");
  }

  Future<void> deleteByJersey(String token, int jersey) async {
    final ok = await _playerProvider.deletePlayer(token, jersey);
    if (!ok) throw Exception("Silme başarısız");
    clear();
  }

  Future<List<PlayerModel>> getByTeam(String token, int teamIdArg) async {
    try {
      if (token.isEmpty || teamIdArg <= 0) {
        throw Exception('Geçersiz token veya takım ID');
      }
      return await _playerProvider.getByTeam(token, teamIdArg);
    } catch (e) {
      debugPrint('PlayerController getByTeam error: $e');
      return <PlayerModel>[];
    }
  }

  void dispose() {
    name.dispose();
    surname.dispose();
    birth_day.dispose();
    height.dispose();
    weight.dispose();
    phone.dispose();
    jersey_number.dispose();
    medical_notes.dispose();
    avatar_url.dispose();
    team_name.dispose();
  }

  void clear() {
    name.clear();
    surname.clear();
    birth_day.clear();
    height.clear();
    weight.clear();
    phone.clear();
    jersey_number.clear();
    medical_notes.clear();
    avatar_url.clear();
    team_name.clear();
    teamId = null;
    position = "Forvet";
    dominant_foot = "right";
    status = "active";
  }
}
