import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'skin_theme.dart';

class SubscriptionPlan {
  final String id, name;
  final int price; // in cents
  final int days;
  const SubscriptionPlan({required this.id, required this.name, required this.price, required this.days});
  static const List<SubscriptionPlan> plans = [
    SubscriptionPlan(id: 'monthly', name: '月付', price: 1000, days: 30),
    SubscriptionPlan(id: 'quarterly', name: '季付', price: 2000, days: 90),
    SubscriptionPlan(id: 'yearly', name: '年付', price: 6500, days: 365),
  ];
  String get priceDisplay => '¥${(price / 100).toStringAsFixed(0)}';
}

final skinProvider = StateNotifierProvider<SkinNotifier, SkinState>((ref) => SkinNotifier());

class SkinState {
  final String currentThemeId;
  final List<String> purchasedThemeIds;
  final bool isPremium;
  final DateTime? premiumExpiry;
  final bool isWechatLoggedIn;
  final String? wechatNickname;

  const SkinState({this.currentThemeId='default', this.purchasedThemeIds=const[], this.isPremium=false, this.premiumExpiry, this.isWechatLoggedIn=false, this.wechatNickname});

  SkinState copyWith({String? currentThemeId, List<String>? purchasedThemeIds, bool? isPremium, DateTime? premiumExpiry, bool? isWechatLoggedIn, String? wechatNickname}) =>
    SkinState(currentThemeId:currentThemeId??this.currentThemeId, purchasedThemeIds:purchasedThemeIds??this.purchasedThemeIds, isPremium:isPremium??this.isPremium, premiumExpiry:premiumExpiry??this.premiumExpiry, isWechatLoggedIn:isWechatLoggedIn??this.isWechatLoggedIn, wechatNickname:wechatNickname??this.wechatNickname);
}

class SkinNotifier extends StateNotifier<SkinState> {
  SkinNotifier() : super(const SkinState()) { _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = SkinState(
      currentThemeId: p.getString('skin_theme') ?? 'default',
      purchasedThemeIds: (p.getStringList('purchased_themes') ?? []),
      isPremium: p.getBool('is_premium') ?? false,
      premiumExpiry: p.getString('premium_expiry') != null ? DateTime.tryParse(p.getString('premium_expiry')!) : null,
      isWechatLoggedIn: p.getBool('wechat_login') ?? false,
      wechatNickname: p.getString('wechat_nickname'),
    );
  }
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('skin_theme', state.currentThemeId);
    await p.setStringList('purchased_themes', state.purchasedThemeIds);
    await p.setBool('is_premium', state.isPremium);
    if (state.premiumExpiry != null) await p.setString('premium_expiry', state.premiumExpiry!.toIso8601String());
    await p.setBool('wechat_login', state.isWechatLoggedIn);
    if (state.wechatNickname != null) await p.setString('wechat_nickname', state.wechatNickname!);
  }
  void setTheme(String id) { if (SkinTheme.freeThemes.any((t) => t.id == id) || state.purchasedThemeIds.contains(id)) { state = state.copyWith(currentThemeId: id); _save(); } }
  void purchaseTheme(String id) { state = state.copyWith(purchasedThemeIds: [...state.purchasedThemeIds, id], currentThemeId: id); _save(); }
  void subscribe(SubscriptionPlan plan) { state = state.copyWith(isPremium: true, premiumExpiry: DateTime.now().add(Duration(days: plan.days))); _save(); }
  void wechatLogin(String nickname) { state = state.copyWith(isWechatLoggedIn: true, wechatNickname: nickname); _save(); }
}
