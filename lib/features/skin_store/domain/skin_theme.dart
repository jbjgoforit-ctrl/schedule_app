import 'package:flutter/material.dart';

class SkinTheme {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color backgroundColor;
  final String? bgImageUrl;
  final String cardStyle; // 'rounded', 'flat', 'glass'
  final String fontFamily;
  final bool isPremium;
  final String? iconData;

  const SkinTheme({
    required this.id, required this.name, required this.description,
    required this.primaryColor, required this.backgroundColor,
    this.bgImageUrl, this.cardStyle = 'rounded',
    this.fontFamily = 'default', this.isPremium = false, this.iconData,
  });

  // For dynamic backgrounds, each theme now has gradient colors
  List<Color> get gradientColors => switch(id) {
    'midnight' => [const Color(0xFF0B0B1A), const Color(0xFF1A0A3E), const Color(0xFF0A1A3E)],
    'sunset' => [const Color(0xFFFF7B00), const Color(0xFFFF5C8A), const Color(0xFFFFF7ED)],
    'ocean' => [const Color(0xFF007CF0), const Color(0xFF00DFD8), const Color(0xFFF0F9FF)],
    'gold' => [const Color(0xFF1A1A2E), const Color(0xFFD4A017), const Color(0xFF16213E)],
    'cherry' => [const Color(0xFFEC4899), const Color(0xFFFDF2F8), const Color(0xFFFCE7F3)],
    _ => [backgroundColor, backgroundColor],
  };

  bool get hasDynamicBg => ['midnight','sunset','ocean','gold'].contains(id);

  static const List<SkinTheme> themes = [
    SkinTheme(id: 'default', name: '经典蓝', description: '默认主题', primaryColor: Color(0xFF6366F1), backgroundColor: Color(0xFFF8FAFC), cardStyle: 'rounded', fontFamily: 'default'),
    SkinTheme(id: 'dark', name: '暗夜模式', description: '护眼深色', primaryColor: Color(0xFFA78BFA), backgroundColor: Color(0xFF0F172A), cardStyle: 'rounded', fontFamily: 'default'),
    SkinTheme(id: 'forest', name: '森林绿', description: '清新自然', primaryColor: Color(0xFF22C55E), backgroundColor: Color(0xFFF0FDF4), cardStyle: 'flat', fontFamily: 'default'),
    SkinTheme(id: 'sunset', name: '日落橙', description: '温暖活力', primaryColor: Color(0xFFF97316), backgroundColor: Color(0xFFFFF7ED), cardStyle: 'rounded', fontFamily: 'default', isPremium: true),
    SkinTheme(id: 'ocean', name: '海洋蓝', description: '深邃宁静', primaryColor: Color(0xFF0EA5E9), backgroundColor: Color(0xFFF0F9FF), cardStyle: 'glass', fontFamily: 'default', isPremium: true),
    SkinTheme(id: 'cherry', name: '樱花粉', description: '浪漫温柔', primaryColor: Color(0xFFEC4899), backgroundColor: Color(0xFFFDF2F8), cardStyle: 'rounded', fontFamily: 'default', isPremium: true),
    SkinTheme(id: 'gold', name: '暗金尊享', description: '奢华质感 + 专属字体', primaryColor: Color(0xFFD4A017), backgroundColor: Color(0xFF1A1A2E), cardStyle: 'glass', fontFamily: 'default', isPremium: true),
    SkinTheme(id: 'midnight', name: '极夜星空', description: '动态渐变背景', primaryColor: Color(0xFF7C3AED), backgroundColor: Color(0xFF0B0B1A), cardStyle: 'glass', fontFamily: 'default', isPremium: true),
  ];

  static SkinTheme get(String id) => themes.firstWhere((t) => t.id == id, orElse: () => themes.first);
  static const List<SkinTheme> freeThemes = [SkinTheme(id: 'default', name: '经典蓝', description: '默认', primaryColor: Color(0xFF6366F1), backgroundColor: Color(0xFFF8FAFC)), SkinTheme(id: 'dark', name: '暗夜', description: '深色', primaryColor: Color(0xFFA78BFA), backgroundColor: Color(0xFF0F172A)), SkinTheme(id: 'forest', name: '森林绿', description: '自然', primaryColor: Color(0xFF22C55E), backgroundColor: Color(0xFFF0FDF4)),];
  static const List<SkinTheme> premiumThemes = [SkinTheme(id: 'sunset', name: '日落橙', description: '温暖', primaryColor: Color(0xFFF97316), backgroundColor: Color(0xFFFFF7ED), isPremium: true), SkinTheme(id: 'ocean', name: '海洋蓝', description: '深邃', primaryColor: Color(0xFF0EA5E9), backgroundColor: Color(0xFFF0F9FF), cardStyle: 'glass', isPremium: true), SkinTheme(id: 'cherry', name: '樱花粉', description: '浪漫', primaryColor: Color(0xFFEC4899), backgroundColor: Color(0xFFFDF2F8), isPremium: true), SkinTheme(id: 'gold', name: '暗金', description: '奢华', primaryColor: Color(0xFFD4A017), backgroundColor: Color(0xFF1A1A2E), cardStyle: 'glass', isPremium: true), SkinTheme(id: 'midnight', name: '极夜', description: '星空', primaryColor: Color(0xFF7C3AED), backgroundColor: Color(0xFF0B0B1A), cardStyle: 'glass', isPremium: true),];
}
