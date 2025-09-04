// lib/pages/coachPage/calendar_page_simple.dart
import 'package:flutter/material.dart';
import 'package:football_app/providers/calender_proivder.dart';
import 'package:provider/provider.dart';

import 'package:football_app/providers/auth_provider.dart';
import 'package:football_app/controllers/calender_controller.dart';
import 'package:football_app/models/calender_model.dart';
import 'package:football_app/pages/coachPage/coach_page.dart';

class CalendarPageSimple extends StatefulWidget {
  const CalendarPageSimple({super.key});

  @override
  State<CalendarPageSimple> createState() => _CalendarPageSimpleState();
}

class _CalendarPageSimpleState extends State<CalendarPageSimple> {
  late final CalenderController _ctrl;
  DateTime _selected = DateTime.now();

  @override
void initState() {
  super.initState();
  _ctrl = CalenderController(context.read<CalenderProvider>());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    final userId = 1; // int veya String

    if (token != null && userId != null) {
      final coachId = userId is int ? userId : int.parse(userId.toString());
      _ctrl.loadForCoach(token: token, coachId: coachId);
    }
  });
}

  String _fmt(BuildContext c, DateTime dt) {
    final ml = MaterialLocalizations.of(c);
    final local = dt.toLocal();
    final d = ml.formatMediumDate(local);
    final t = ml.formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: true);
    return '$d • $t';
  }

  Future<void> _openForm({CalenderModel? editing}) async {
    final form = CalenderForm(
      initialStart: editing?.startDate ?? DateTime(_selected.year, _selected.month, _selected.day, 18, 0),
      initialEnd: editing?.endDate,
      title: editing?.title,
      description: editing?.description,
      location: editing?.location,
    );

    final auth = context.read<AuthProvider>();
    final token = auth.token!;
    final userId = 1;
    final coachId = userId is int ? userId : int.parse(userId.toString());

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EventFormSheet(
        form: form,
        title: editing == null ? 'Etkinlik Ekle' : 'Etkinliği Düzenle',
        onSubmit: (f) async {
          if (editing == null) {
            await _ctrl.addEvent(token: token, coachId: coachId, form: f);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eklendi')));
          } else {
            await _ctrl.updateEvent(token: token, current: editing, form: f);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Güncellendi')));
          }
          await _ctrl.refresh(token: token);
        },
        onDelete: editing == null
            ? null
            : () async {
                await _ctrl.deleteEvent(token: token, id: editing.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silindi')));
                await _ctrl.refresh(token: token);
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CalenderProvider>();
    final dayItems = prov.eventsOn(_selected);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Takvim',
          style: TextStyle(color: Color(0xFF7B5CC9), fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color:Color(0xFF7B5CC9)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CoachPage()),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7B5CC9),
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: _selected,
            firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
            lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
            onDateChanged: (d) => setState(() => _selected = d),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(MaterialLocalizations.of(context).formatFullDate(_selected),
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: prov.loading
                ? const Center(child: CircularProgressIndicator())
                : prov.error != null
                    ? Center(child: Text(prov.error!))
                    : RefreshIndicator(
                        onRefresh: () async {
                          final token = context.read<AuthProvider>().token!;
                          await _ctrl.refresh(token: token);
                        },
                        child: dayItems.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 80),
                                  Center(child: Text('Bugün için kayıt yok')),
                                ],
                              )
                            : ListView.separated(
                                itemCount: dayItems.length,
                                separatorBuilder: (_, __) => const Divider(height: 0),
                                itemBuilder: (_, i) {
                                  final e = dayItems[i];
                                  final when = _fmt(context, e.startDate) +
                                      (e.endDate != null ? ' → ${_fmt(context, e.endDate!)}' : '');
                                  final subtitle = e.location == null || e.location!.isEmpty
                                      ? when
                                      : '$when\n${e.location}';
                                  return ListTile(
                                    leading: const Icon(Icons.event),
                                    title: Text(e.title),
                                    subtitle: Text(subtitle),
                                    isThreeLine: e.location != null && e.location!.isNotEmpty,
                                    onTap: () => _openForm(editing: e), // tıkla → düzenle/sil
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ----------------- BottomSheet (Ekle/Düzenle) -----------------
class _EventFormSheet extends StatefulWidget {
  final CalenderForm form;
  final String title;
  final Future<void> Function(CalenderForm) onSubmit;
  final Future<void> Function()? onDelete; // null ise gizli

  const _EventFormSheet({
    required this.form,
    required this.title,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  State<_EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends State<_EventFormSheet> {
  @override
  void dispose() {
    widget.form.dispose(); // controller'ları sheet kapatılırken serbest bırak
    super.dispose();
  }

  String _fmt(BuildContext c, DateTime dt) {
    final ml = MaterialLocalizations.of(c);
    final local = dt.toLocal();
    return '${ml.formatMediumDate(local)} • '
        '${ml.formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: true)}';
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime initial) async {
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (d == null) return null;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = const SizedBox(height: 10);
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 12,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    if (widget.onDelete != null)
                      IconButton(
                        tooltip: 'Sil',
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Silinsin mi?'),
                              content: const Text('Bu etkinlik silinecek.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
                                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
                              ],
                            ),
                          );
                          if (ok == true) {
                            await widget.onDelete!();
                            if (mounted) Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                  ],
                ),
                spacing,
                TextField(
                  controller: widget.form.titleCtrl,
                  decoration: const InputDecoration(labelText: 'Başlık', border: OutlineInputBorder()),
                ),
                spacing,
                TextField(
                  controller: widget.form.descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()),
                ),
                spacing,
                TextField(
                  controller: widget.form.locCtrl,
                  decoration: const InputDecoration(labelText: 'Konum', border: OutlineInputBorder()),
                ),
                spacing,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final v = await _pickDateTime(context, widget.form.start!);
                          if (v != null) setState(() => widget.form.start = v);
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Başlangıç', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                              const SizedBox(height: 4),
                              Text(_fmt(context, widget.form.start!),
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final init = widget.form.end ?? widget.form.start!.add(const Duration(hours: 1));
                          final v = await _pickDateTime(context, init);
                          if (v != null) setState(() => widget.form.end = v);
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bitiş', style: TextStyle(color: Colors.black.withOpacity(0.6))),
                              const SizedBox(height: 4),
                              Text(_fmt(context, widget.form.end ?? widget.form.start!.add(const Duration(hours: 1))),
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: () async {
                      final err = widget.form.validate();
                      if (err != null) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                        return;
                      }
                      await widget.onSubmit(widget.form);
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text('Kaydet'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
