import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});
  @override State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _ctrl = TextEditingController();
  @override void dispose() {_ctrl.dispose();super.dispose();}

  @override Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('建议反馈')),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        TextField(controller: _ctrl, maxLines: 8, decoration: const InputDecoration(hintText: '请输入你的建议或遇到的问题...', border: OutlineInputBorder(), alignLabelWithHint: true)),
        const SizedBox(height: 16),
        FilledButton.icon(icon: const Icon(Icons.send), label: const Text('提交反馈'), onPressed: () {
          if (_ctrl.text.trim().isNotEmpty) {
            ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('感谢你的反馈！')));
            _ctrl.clear();
          }
        }),
      ])),
    );
  }
}
