// lib/providers/calender_provider.dart
import 'package:flutter/material.dart';
import '../models/calender_model.dart';
import '../service/calender_service.dart';

class CalenderProvider with ChangeNotifier {
  final CalenderService _service;

  CalenderProvider({CalenderService? service})
    : _service = service ?? CalenderService();

  List<CalenderModel> _items = [];
  bool _loading = false;
  String? _error;

  int? _lastCoachId;
  DateTime? _lastRangeStart;
  DateTime? _lastRangeEnd;

  List<CalenderModel> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;
  DateTime? get lastRangeStart => _lastRangeStart;
  DateTime? get lastRangeEnd => _lastRangeEnd;
  int? get lastCoachId => _lastCoachId;

  void _setLoading(bool v) {
    if (_loading == v) return;
    _loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  void _setItems(List<CalenderModel> list) {
    _items = List.of(list);
    _items.sort((a, b) => a.startDate.compareTo(b.startDate));
    notifyListeners();
  }

  Future<void> loadForCoach({
    required String token,
    required int coachId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      final list = await _service.getList(token, coachId);
      _setItems(list);
      _lastCoachId = coachId;
      _lastRangeStart = null;
      _lastRangeEnd = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadByDate({
    required String token,
    required int coachId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      final list = await _service.getListByDate(token, coachId, start, end);
      _setItems(list);
      _lastCoachId = coachId;
      _lastRangeStart = start;
      _lastRangeEnd = end;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh({required String token}) async {
    if (_lastCoachId == null) return;
    if (_lastRangeStart != null && _lastRangeEnd != null) {
      await loadByDate(
        token: token,
        coachId: _lastCoachId!,
        start: _lastRangeStart!,
        end: _lastRangeEnd!,
      );
    } else {
      await loadForCoach(token: token, coachId: _lastCoachId!);
    }
  }

  Future<int> add({
    required String token,
    required CalenderModel calender,
  }) async {
    final id = await _service.calenderAdd(token, calender);
    await refresh(token: token);
    return id;
  }

  Future<void> update({
    required String token,
    required CalenderModel calender,
  }) async {
    await _service.calenderUpdate(token, calender);
    await refresh(token: token);
  }

  Future<void> remove({required String token, required int id}) async {
    await _service.calenderDelete(token, id);
    await refresh(token: token);
  }

  List<CalenderModel> eventsOn(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final list =
        _items.where((e) {
          final s = e.startDate;
          final ed = e.endDate ?? e.startDate;
          return s.isBefore(end) && ed.isAfter(start);
        }).toList();
    list.sort((a, b) => a.startDate.compareTo(b.startDate));
    return list;
  }

  void clear() {
    _items = [];
    _loading = false;
    _error = null;
    _lastCoachId = null;
    _lastRangeStart = null;
    _lastRangeEnd = null;
    notifyListeners();
  }
}
