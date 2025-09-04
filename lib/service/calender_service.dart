import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/calender_model.dart';

class CalenderService {
  final String baseUrl = 'http://172.20.10.5:3000/api';

  Future<List<CalenderModel>> getList(String token, int coachId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/calender/$coachId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => CalenderModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load calendar');
    }
  }

  Future<List<CalenderModel>> getListByDate(
    String token,
    int coachId,
    DateTime start,
    DateTime end,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/calender/$coachId?start=${start.toIso8601String()}&end=${end.toIso8601String()}',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => CalenderModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load calendar by date');
    }
  }

  Future<int> calenderAdd(String token, CalenderModel calender) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/calender/calenderAdd'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(calender.toJson()),
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = json.decode(resp.body);
      final id = data['id'] ?? data['insertId'];
      if (id == null) {
        throw Exception('Add ok but id missing: ${resp.body}');
      }
      return id is int ? id : int.parse(id.toString());
    } else {
      throw Exception(
        'Failed to add calendar: ${resp.statusCode} ${resp.body}',
      );
    }
  }

  Future<void> calenderUpdate(String token, CalenderModel calender) async {
    final response = await http.put(
      Uri.parse('$baseUrl/calender/calenderUpdate/${calender.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(calender.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update calendar');
    }
  }

  Future<void> calenderDelete(String token, int calenderId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/calender/calenderDelete/$calenderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete calendar');
    }
  }
}
