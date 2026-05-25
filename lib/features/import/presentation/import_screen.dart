import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'import_provider.dart';
import 'import_method_card.dart';
import '../../settings/domain/settings_provider.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/course.dart';
import '../../../data/datasources/remote/school_sites.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});
  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importStateProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('导入课表')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (state.isLoading) const LinearProgressIndicator(),
        if (state.errorMessage != null) _msg(state.errorMessage!, isError: true),
        if (state.successMessage != null && state.previewCourses.isEmpty)
          _msg(state.successMessage!, isError: false),
        ImportMethodCard(title: '粘贴HTML源码', subtitle: '从电脑或手机浏览器复制课表页面HTML源码', icon: Icons.code, onTap: _showHtmlDialog),
        const SizedBox(height: 12),
        ImportMethodCard(title: 'WebView 导入', subtitle: 'App内直接打开教务网站登录后抓取', icon: Icons.account_circle, onTap: _showSchoolSheet),
        if (state.previewCourses.isNotEmpty) ...[
          const SizedBox(height: 24),
          _preview(state.previewCourses),
        ],
      ]),
    );
  }

  Widget _msg(String m, {required bool isError}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isError ? AppColors.error : AppColors.success).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? AppColors.error : AppColors.success, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(m, style: TextStyle(color: isError ? AppColors.error : AppColors.success, fontSize: 14))),
      ]),
    );
  }

  Widget _preview(List<Course> courses) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('预览 (${courses.length}门)', style: AppTextStyles.heading3),
        const Spacer(),
        TextButton(onPressed: () => ref.read(importStateProvider.notifier).clearPreview(), child: const Text('清除')),
        FilledButton(onPressed: () => ref.read(importStateProvider.notifier).saveCourses(), child: const Text('保存到课表')),
      ]),
      const SizedBox(height: 8),
      ...courses.take(10).map((c) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _parseColor(c.colorHex),
                child: Text(c.name.characters.take(2).toString(), style: AppTextStyles.courseTitle),
              ),
              title: Text(c.name, style: AppTextStyles.body),
              subtitle: Text('${c.teacher} | ${c.location} | 周${c.dayOfWeek}', style: AppTextStyles.caption),
              dense: true,
            ),
          )),
      if (courses.length > 10)
        Padding(padding: const EdgeInsets.all(8), child: Text('...还有 ${courses.length - 10} 门', style: AppTextStyles.caption)),
    ]);
  }

  Color _parseColor(String hex) {
    try {return Color(int.parse(hex.replaceFirst('#', '0xFF')));} catch (_) {return AppColors.primary;}
  }

  void _showSchoolSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => const _SchoolSelectSheet(),
    );
  }

  void _showHtmlDialog() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('粘贴HTML源码', style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          TextField(controller: ctrl, maxLines: 6, decoration: const InputDecoration(hintText: '在电脑浏览器中打开课表页面,右键查看源码,全选复制,粘贴到这里', border: OutlineInputBorder(), alignLabelWithHint: true)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                ref.read(importStateProvider.notifier).importFromHtml(ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('解析课表'),
          ),
        ]),
      ),
    );
  }
}

// ─── School Select Sheet ───

class _SchoolSelectSheet extends ConsumerStatefulWidget {
  const _SchoolSelectSheet();
  @override ConsumerState<_SchoolSelectSheet> createState() => _SchoolSelectSheetState();
}

class _SchoolSelectSheetState extends ConsumerState<_SchoolSelectSheet> {
  SchoolSite? _sel;String _systemType='zhengfang';
  final _urlCtrl = TextEditingController();
  @override void dispose() {_urlCtrl.dispose();super.dispose();}
  Widget _buildSystemTypePicker(){return DropdownButtonFormField<String>(value:_systemType,decoration:const InputDecoration(labelText:'教务系统类型',border:OutlineInputBorder(),prefixIcon:Icon(Icons.category,size:18)),items:JwSystemTemplate.all.map((t)=>DropdownMenuItem(value:t.id,child:Text(t.name))).toList(),onChanged:(v){if(v!=null){setState((){_systemType=v;_urlCtrl.text=JwSystemTemplate.all.firstWhere((t)=>t.id==v).urlHint;});ref.read(importStateProvider.notifier).setSystemType(v);}});}

  String get _targetUrl {final c = _urlCtrl.text.trim();if (c.isNotEmpty) return c;return _sel?.url ?? '';}
  String get _targetName {final c = _urlCtrl.text.trim();if (c.isNotEmpty) {final u = Uri.tryParse(c);return u?.host ?? 'custom';}return _sel?.name ?? '';}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('账号密码导入', style: AppTextStyles.heading2),
        const SizedBox(height: 4),
        Text('选择教务系统类型，自动填入对应网址', style: AppTextStyles.caption),
        const SizedBox(height: 16),
        // System type picker
        _buildSystemTypePicker(),
        const SizedBox(height: 12),
        TextField(
          controller: _urlCtrl,
          decoration: InputDecoration(labelText: '直接输入教务网站地址', hintText: 'https://jwxt.example.edu.cn', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.link, size: 18)),
          keyboardType: TextInputType.url,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(children: [const Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('或者选学校', style: AppTextStyles.caption)), const Expanded(child: Divider())]),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showSearch, borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: const InputDecoration(labelText: '选择学校快速填入', border: OutlineInputBorder(), prefixIcon: Icon(Icons.school, size: 18), suffixIcon: Icon(Icons.search)),
            child: Text(_sel != null ? _sel!.name : '搜索 985 高校', style: TextStyle(color: _sel != null ? AppColors.textPrimary : AppColors.textHint, fontSize: 15)),
          ),
        ),
        if (_sel != null)
          Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 14),
            const SizedBox(width: 4),
            Expanded(child: Text(_sel!.url, style: const TextStyle(fontSize: 11, color: AppColors.success))),
            GestureDetector(onTap: () => setState(() => _sel = null), child: const Text('清除', style: TextStyle(fontSize: 11, color: AppColors.primary))),
          ])),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8)),
          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.warning_amber, size: 16, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('登录后请导航到个人课表页面并选择正确学期。\n校外访问请先连接学校VPN。\n调课/停课信息无法自动导入，请导入后自行修改。', style: TextStyle(fontSize: 11, color: Color(0xFFBF360C), height: 1.4))),
          ]),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          icon: const Icon(Icons.open_in_browser),
          label: const Text('前往教务系统'),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: (_sel != null || _targetUrl.isNotEmpty)
              ? () {
                  final custom = _urlCtrl.text.trim();
                  if (custom.isNotEmpty) {
                    final u = Uri.tryParse(custom);
                    SchoolSite.addCustom(u?.host??custom,custom,_systemType);
                  }
                  if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('当前平台不支持'),
                        content: const Text('WebView仅支持Android/iOS。请在电脑浏览器中登录教务后使用"粘贴HTML源码"导入。'),
                        actions: [TextButton(onPressed: () {Navigator.pop(c);}, child: const Text('知道了'))],
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  context.pushNamed('import_webview', extra: {'url': _targetUrl, 'name': _targetName});
                }
              : null,
        ),
      ]),
    );
  }

  void _showSearch() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _SchoolSearchSheet(onSelect: (school) {
            setState(() {_sel = school;_urlCtrl.clear();});
            Navigator.pop(ctx);
          }),
    );
  }
}

// ─── School Search Sheet ───

class _SchoolSearchSheet extends StatefulWidget {
  final void Function(SchoolSite) onSelect;
  const _SchoolSearchSheet({required this.onSelect});
  @override State<_SchoolSearchSheet> createState() => _SchoolSearchSheetState();
}

class _SchoolSearchSheetState extends State<_SchoolSearchSheet> {
  final _sr = TextEditingController();
  List<SchoolSite> _res = [];

  @override void initState() {super.initState();_sr.addListener(_f);_load();}
  Future<void> _load() async {final c = await SchoolSite.loadCustom();setState(() => _res = [...c, ...SchoolSite.all]);}
  void _f() async {final all = await SchoolSite.searchAsync(_sr.text);setState(() => _res = all);}
  @override void dispose() {_sr.dispose();super.dispose();}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('选择学校', style: AppTextStyles.heading2),
        const SizedBox(height: 4),
        Text('39 所 985 + 自定义', style: AppTextStyles.caption),
        const SizedBox(height: 16),
        TextField(controller: _sr, decoration: const InputDecoration(hintText: '搜索学校名称...', border: OutlineInputBorder(), prefixIcon: Icon(Icons.search)), autofocus: true),
        const SizedBox(height: 12),
        SizedBox(
          height: 400,
          child: ListView.builder(itemCount: _res.length, itemBuilder: (_, i) {
            final s = _res[i];
            return ListTile(
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: s.isCustom ? AppColors.warning : AppColors.courseColor(i), borderRadius: BorderRadius.circular(8)),
                child: Center(child: Icon(s.isCustom ? Icons.push_pin : Icons.school, color: Colors.white, size: 18)),
              ),
              title: Row(children: [
                Expanded(child: Text(s.name)),
                if (s.isCustom) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(4)), child: const Text('我的', style: TextStyle(fontSize: 10, color: AppColors.warning))),
              ]),
              subtitle: Text(s.url, style: AppTextStyles.caption.copyWith(fontSize: 11)),
              trailing: s.isCustom ? IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () async {await SchoolSite.removeCustom(s.url);_f();}) : const Icon(Icons.chevron_right, size: 18),
              onTap: () => widget.onSelect(s),
            );
          }),
        ),
      ]),
    );
  }
}
