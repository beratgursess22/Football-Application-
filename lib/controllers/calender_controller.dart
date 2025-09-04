import 'package:flutter/material.dart';
import 'package:football_app/providers/calender_proivder.dart';
import '../models/calender_model.dart';

class CalenderController {
  final CalenderProvider provider;
  CalenderController(this.provider);

  bool get loading => provider.loading;
  String? get error => provider.error;
  List<CalenderModel> get items => provider.items;

  Future<void> loadForCoach({required String token, required int coachId}) {
    return provider.loadForCoach(token: token, coachId: coachId);
  }

  Future<void> loadByDate({
    required String token,
    required int coachId,
    required DateTime start,
    required DateTime end,
  }) {
    return provider.loadByDate(
      token: token,
      coachId: coachId,
      start: start,
      end: end,
    );
  }

  Future<void> refresh({required String token}) {
    return provider.refresh(token: token);
  }

  // ---- CRUD ----
  Future<int> addEvent({
    required String token,
    required int coachId,
    required CalenderForm form,
  }) async {
    final err = form.validate();
    if (err != null) throw Exception(err);

    final model = CalenderModel(
      id: 0,
      coachId: coachId,
      title: form.titleCtrl.text.trim(),
      description: _nullIfEmpty(form.descCtrl.text),
      startDate: form.start!,
      endDate: form.end,
      location: _nullIfEmpty(form.locCtrl.text),
      createdAt: null,
      updatedAt: null,
    );

    final id = await provider.add(token: token, calender: model);
    return id; // provider zaten refresh çağırıyor
  }

  Future<void> updateEvent({
    required String token,
    required CalenderModel current,
    required CalenderForm form,
  }) async {
    final err = form.validate();
    if (err != null) throw Exception(err);

    final updated = CalenderModel(
      id: current.id,
      coachId: current.coachId,
      title: form.titleCtrl.text.trim(),
      startDate: form.start!,
      endDate: form.end,
      location: _nullIfEmpty(form.locCtrl.text),  
    );


    await provider.update(
      token: token,
      calender: updated,
    );
  }

  Future<void> deleteEvent({required String token, required int id}) {
    return provider.remove(token: token, id: id);
  }

  List<CalenderModel> eventsOn(DateTime day) => provider.eventsOn(day);

  String? _nullIfEmpty(String? s) {
    if (s == null) return null;
    final t = s.trim();
    return t.isEmpty ? null : t;
  }
}

class CalenderForm {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController locCtrl = TextEditingController();

  DateTime? start; // zorunlu
  DateTime? end; // opsiyonel

  CalenderForm({
    DateTime? initialStart,
    DateTime? initialEnd,
    String? title,
    String? description,
    String? location,
  }) {
    start = initialStart ?? DateTime.now().add(const Duration(hours: 1));
    end = initialEnd ?? (start?.add(const Duration(hours: 1)));
    if (title != null) titleCtrl.text = title;
    if (description != null) descCtrl.text = description;
    if (location != null) locCtrl.text = location;
  }
  void fillFromModel(CalenderModel m) {
    titleCtrl.text = m.title;
    descCtrl.text = m.description ?? '';
    locCtrl.text = m.location ?? '';
    start = m.startDate;
    end = m.endDate;
  }

  String? validate() {
    if (titleCtrl.text.trim().isEmpty) {
      return 'Başlık zorunludur.';
    }
    if (start == null) {
      return 'Başlangıç zamanı zorunludur.';
    }
    if (end != null && end!.isBefore(start!)) {
      return 'Bitiş, başlangıçtan önce olamaz.';
    }
    return null;
  }

  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    locCtrl.dispose();
  }
}
