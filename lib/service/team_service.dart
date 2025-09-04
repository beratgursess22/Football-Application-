import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/team_model.dart';

class TeamService {
  final String baseUrl = 'http://172.20.10.5:3000';

  Future<TeamModel> addTeam(String token, String name) async {
    final uri = Uri.parse('$baseUrl/api/teams/teamAdd');
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final teamJson = data['team'] ?? data;
      return TeamModel.fromJson(teamJson);
    }
    throw Exception('Takım : ${res.statusCode} ${res.body}');
  }

  Future<bool> deleteTeam(String token, String name) async {
    final uri = Uri.parse('$baseUrl/api/teams/teamDelete');
    final res = await http.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );
    if (res.statusCode == 200 || res.statusCode == 204) {
      return true;
    }
    return false;
  }

  Future<List<TeamModel>> getTeams(String token) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/teams'),
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
            .map((e) => TeamModel.fromJson(e))
            .toList();
      }
      throw Exception('Beklenmeyen veri formatı: ${resp.body}');
    }

    throw Exception('Getirme başarısız (${resp.statusCode}): ${resp.body}');
  }

  Future<TeamModel> getTeamById(String token, int id) async {
    final resp = await http.get(
      Uri.parse('$baseUrl/api/teams/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      if (body is Map<String, dynamic>) {
        return TeamModel.fromJson(body);
      }
      if (body is List &&
          body.isNotEmpty &&
          body.first is Map<String, dynamic>) {
        return TeamModel.fromJson(body.first as Map<String, dynamic>);
      }
      throw Exception('Beklenmeyen veri formatı: ${resp.body}');
    }
    print("id: $id");
    if (resp.statusCode == 404) {
      throw Exception('Takım bulunamadı (id=$id)');
    }
    throw Exception('Getirme başarısız (${resp.statusCode}): ${resp.body}');
  }
}
