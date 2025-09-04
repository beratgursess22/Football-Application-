import 'dart:convert';
import 'package:football_app/models/player_model.dart';
import 'package:http/http.dart' as http;

class PlayerService {
  final String baseUrl = 'http://172.20.10.5:3000';

  Future<int> addPlayer(String token, Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/players/playerAdd'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final dynamic idAny =
          data['playerId'] ??
          data['player_id'] ??
          data['id'] ??
          data['insertId'];
      if (idAny is int) return idAny;
      if (idAny is String)
        return int.tryParse(idAny) ??
            (throw Exception('id parse edilemedi: $idAny'));
      throw Exception('201 döndü ama id bulunamadı: ${response.body}');
    } else {
      throw Exception('kayıt başarısız: ${response.body}');
    }
  }

  Future<void> deletePlayer(String token, int jerseyNumber) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/players/$jerseyNumber'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception("Silme işlemi başarısız");
    }
  }

  Future<void> updatePlayer(
    String token,
    int jerseyNumber,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/players/$jerseyNumber'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception("Güncelleme işlemi başarısız");
    }
  }

  Future<Map<String, dynamic>> getPlayer(String token, int jerseyNumber) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/players/$jerseyNumber'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is List && data.isNotEmpty) {
        return data[0] as Map<String, dynamic>;
      } else {
        throw Exception('Beklenmeyen veri formatı: $data');
      }
    } else {
      throw Exception('Getirme başarısız: ${response.body}');
    }
  }

  Future<List<PlayerModel>> getByTeam(String token, int teamId) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/players?team_id=$teamId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      if (body is List) {
        return body
            .whereType<Map<String, dynamic>>()
            .map(PlayerModel.fromJson)
            .toList();
      }
      throw Exception('Beklenmeyen veri formatı: ${resp.body}');
    }
    throw Exception(
      'Oyuncular getirilemedi (${resp.statusCode}): ${resp.body}',
    );
  }
}
