import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/skin_theme.dart';
import '../domain/skin_provider.dart';
import '../../../../core/constants/app_colors.dart';

class SkinStoreScreen extends ConsumerWidget {
  const SkinStoreScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final skin = ref.watch(skinProvider);
    final theme = SkinTheme.get(skin.currentThemeId);
    return Scaffold(
      appBar: AppBar(title: const Text('皮肤商店'), actions: [if (!skin.isWechatLoggedIn) TextButton.icon(icon: const Icon(Icons.login), label: const Text('微信登录'), onPressed: () => _showWechatLogin(context, ref)) else Padding(padding: const EdgeInsets.only(right:8), child: Chip(avatar: const Icon(Icons.person,size:16), label: Text(skin.wechatNickname??'用户')))]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (skin.isPremium) _buildPremiumBadge(skin),
        const SizedBox(height: 8),
        Text('免费主题', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 12),
        ...SkinTheme.freeThemes.map((t) => _buildThemeCard(context, ref, t, skin)),
        const SizedBox(height: 20),
        Row(children: [Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [const Icon(Icons.diamond, color: AppColors.warning, size: 18), const SizedBox(width: 4), const Text('高级主题', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold))])), Expanded(child: Divider())]),
        const SizedBox(height: 12),
        if (!skin.isPremium) _buildPricingCards(context, ref),
        ...SkinTheme.premiumThemes.map((t) => _buildThemeCard(context, ref, t, skin, locked: !skin.isPremium && !skin.purchasedThemeIds.contains(t.id))),
      ]),
    );
  }

  Widget _buildPremiumBadge(SkinState skin) {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFD4A017), Color(0xFF1A1A2E)]), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.workspace_premium, color: Colors.amber, size: 40), const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('高级会员', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text('到期: ${skin.premiumExpiry != null ? '${skin.premiumExpiry!.month}/${skin.premiumExpiry!.day}' : '永久'}', style: const TextStyle(color: Colors.white70, fontSize: 13))])),
      ]),
    );
  }

  Widget _buildThemeCard(BuildContext context, WidgetRef ref, SkinTheme t, SkinState skin, {bool locked = false}) {
    final isActive = skin.currentThemeId == t.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: locked ? () => _showSubscribeDialog(context, ref) : () { ref.read(skinProvider.notifier).setTheme(t.id); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已切换到${t.name}主题'), duration: const Duration(seconds: 1))); },
        child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Container(width: 50, height: 50, decoration: BoxDecoration(gradient: LinearGradient(colors: t.hasDynamicBg ? t.gradientColors : [t.primaryColor, t.backgroundColor]), borderRadius: BorderRadius.circular(12), border: isActive ? Border.all(color: AppColors.success, width: 3) : null), child: locked ? const Icon(Icons.lock, color: Colors.white54, size: 22) : const SizedBox()),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(t.description, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))])),
          if (isActive) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: const Text('使用中', style: TextStyle(fontSize: 11, color: AppColors.success))),
          if (locked) const Icon(Icons.chevron_right, color: Colors.grey),
        ])),
      ),
    );
  }

  Widget _buildPricingCards(BuildContext context, WidgetRef ref) {
    return Column(children: [
      const Text('解锁全部高级主题', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      Row(children: SubscriptionPlan.plans.map((p) => Expanded(child: Card(child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => _showPaymentDialog(context, ref, p), child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(p.priceDisplay, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)), const SizedBox(height: 2), Text('${p.days}天', style: const TextStyle(fontSize: 11, color: Colors.grey))])))))).toList()),
    ]);
  }

  void _showSubscribeDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (c) => AlertDialog(title: const Text('高级主题'), content: const Text('需要开通高级会员才能使用此主题'), actions: [
      TextButton(onPressed: () => Navigator.pop(c), child: const Text('取消')),
      FilledButton(onPressed: () { Navigator.pop(c); _showPaymentDialog(context, ref, SubscriptionPlan.plans.first); }, child: const Text('开通会员')),
    ]));
  }

  void _showPaymentDialog(BuildContext context, WidgetRef ref, SubscriptionPlan plan) {
    showDialog(context: context, builder: (c) => AlertDialog(title: const Text('确认支付'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('${plan.name} · ${plan.priceDisplay}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12), Text('${plan.days}天高级会员', style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 20),
      _buildPaymentMethod('微信支付', Icons.wechat, Colors.green),
      const SizedBox(height: 8),
      _buildPaymentMethod('支付宝', Icons.account_balance_wallet, Colors.blue),
    ]), actions: [
      TextButton(onPressed: () => Navigator.pop(c), child: const Text('取消')),
      FilledButton(onPressed: () { ref.read(skinProvider.notifier).subscribe(plan); Navigator.pop(c); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('购买成功！已开通高级会员'), backgroundColor: AppColors.success)); }, child: const Text('确认支付')),
    ]));
  }

  Widget _buildPaymentMethod(String name, IconData icon, Color color) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(icon, color: color, size: 24), const SizedBox(width: 10), Text(name, style: const TextStyle(fontSize: 15))]));
  }

  void _showWechatLogin(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(title: const Text('微信登录'), content: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.wechat, color: Colors.green, size: 48),
      const SizedBox(height: 12),
      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '微信昵称', border: OutlineInputBorder())),
    ]), actions: [
      TextButton(onPressed: () => Navigator.pop(c), child: const Text('取消')),
      FilledButton(onPressed: () { if (nameCtrl.text.trim().isNotEmpty) { ref.read(skinProvider.notifier).wechatLogin(nameCtrl.text.trim()); Navigator.pop(c); } }, child: const Text('登录')),
    ]));
  }
}
