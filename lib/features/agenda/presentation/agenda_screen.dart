import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class AgendaItem {
  final String id, title, desc;
  final DateTime date;
  final bool done;
  const AgendaItem({required this.id, required this.title, this.desc = '', required this.date, this.done = false});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'desc': desc, 'date': date.toIso8601String(), 'done': done};
  factory AgendaItem.fromJson(Map<String, dynamic> j) => AgendaItem(id: j['id'], title: j['title'], desc: j['desc'] ?? '', date: DateTime.parse(j['date']), done: j['done'] ?? false);
  AgendaItem copyWith({String? title, String? desc, DateTime? date, bool? done}) => AgendaItem(id: id, title: title ?? this.title, desc: desc ?? this.desc, date: date ?? this.date, done: done ?? this.done);
}

final agendaProvider = StateNotifierProvider<AgendaNotifier, List<AgendaItem>>((ref) => AgendaNotifier());

class AgendaNotifier extends StateNotifier<List<AgendaItem>> {
  AgendaNotifier() : super([]) { _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final j = p.getString('agenda_items');
    if (j != null) {
      try {
        final list = jsonDecode(j) as List;
        state = list.map((e) => AgendaItem.fromJson(e)).toList()..sort((a, b) => a.date.compareTo(b.date));
      } catch (_) {}
    }
  }
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('agenda_items', jsonEncode(state.map((e) => e.toJson()).toList()));
  }
  void add(AgendaItem item) { state = [...state, item]..sort((a, b) => a.date.compareTo(b.date)); _save(); }
  void update(int idx, AgendaItem item) { state = [...state]..[idx] = item..sort((a, b) => a.date.compareTo(b.date)); _save(); }
  void remove(int idx) { state = [...state]..removeAt(idx); _save(); }
  void toggle(int idx) { final item = state[idx]; state = [...state]..[idx] = item.copyWith(done: !item.done); _save(); }
}

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(agendaProvider);
    final today = DateTime.now();
    final todayItems = items.where((i) => i.date.year == today.year && i.date.month == today.month && i.date.day == today.day).toList();
    final upcoming = items.where((i) => i.date.isAfter(today) && !(i.date.year == today.year && i.date.month == today.month && i.date.day == today.day)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('日程管理')),
      body: items.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.event_note, size: 64, color: AppColors.textHint), const SizedBox(height: 16), Text('还没有日程', style: AppTextStyles.body), const SizedBox(height: 8), Text('点击右下角 + 添加考试、作业、活动', style: AppTextStyles.caption)]))
          : ListView(padding: const EdgeInsets.all(16), children: [
              if (todayItems.isNotEmpty) ...[
                Text('今天', style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
                const SizedBox(height: 8),
                ...todayItems.asMap().entries.map((e) => _buildItem(context, e.key, e.value, ref)),
                const SizedBox(height: 16),
              ],
              if (upcoming.isNotEmpty) ...[
                Text('即将到来', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                ...upcoming.asMap().entries.map((e) => _buildItem(context, items.indexOf(e.value), e.value, ref)),
              ],
            ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItem(BuildContext ctx, int idx, AgendaItem item, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: item.done,
          onChanged: (_) => ref.read(agendaProvider.notifier).toggle(idx),
          activeColor: AppColors.success,
        ),
        title: Text(item.title, style: TextStyle(decoration: item.done ? TextDecoration.lineThrough : null, color: item.done ? AppColors.textHint : AppColors.textPrimary)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${item.date.month}/${item.date.day} ${item.date.hour}:${item.date.minute.toString().padLeft(2, '0')}', style: AppTextStyles.caption),
          if (item.desc.isNotEmpty) Text(item.desc, style: AppTextStyles.caption),
        ]),
        trailing: IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => ref.read(agendaProvider.notifier).remove(idx)),
        onTap: () => _showEditor(ctx, ref, editIdx: idx, editItem: item),
      ),
    );
  }

  void _showEditor(BuildContext context, WidgetRef ref, {int? editIdx, AgendaItem? editItem}) {
    final titleCtrl = TextEditingController(text: editItem?.title ?? '');
    final descCtrl = TextEditingController(text: editItem?.desc ?? '');
    DateTime date = editItem?.date ?? DateTime.now().add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setD) => AlertDialog(
          title: Text(editItem != null ? '编辑日程' : '添加日程'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: '标题', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: '备注', border: OutlineInputBorder()), maxLines: 2),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('日期'),
              subtitle: Text('${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () async {
                final d = await showDatePicker(context: c, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2030));
                if (d != null) {
                  final t = await showTimePicker(context: c, initialTime: TimeOfDay.fromDateTime(date));
                  if (t != null) { setD(() => date = DateTime(d.year, d.month, d.day, t.hour, t.minute)); }
                }
              },
            ),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text('取消')),
            FilledButton(onPressed: () {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;
              final item = AgendaItem(id: editItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), title: title, desc: descCtrl.text.trim(), date: date);
              if (editItem != null) {
                ref.read(agendaProvider.notifier).update(editIdx!, item);
              } else {
                ref.read(agendaProvider.notifier).add(item);
              }
              Navigator.pop(c);
            }, child: const Text('保存')),
          ],
        ),
      ),
    );
  }
}
