import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _buildCard(Icons.palette_outlined, '皮肤商店', () => context.pushNamed('skin_store')),
        const SizedBox(height: 8),
        _buildCard(Icons.settings, '设置', () => context.pushNamed('settings')),
        const SizedBox(height: 8),
        _buildCard(Icons.feedback_outlined, '建议反馈', () => context.pushNamed('feedback')),
        const SizedBox(height: 8),
        _buildCard(Icons.help_outline, '使用帮助', () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('帮助文档即将上线')));
        }),
        const SizedBox(height: 8),
        _buildCard(Icons.info_outline, '关于', () {
          showAboutDialog(context: context, applicationName: '我的课表', applicationVersion: '1.0.0', applicationLegalese: '© 2026');
        }),
      ]),
    );
  }

  Widget _buildCard(IconData icon, String title, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
