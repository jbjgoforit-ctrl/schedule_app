import 'package:flutter/material.dart';
class AppColors {
  AppColors._();
  static const Color primary=Color(0xFF6366F1),primaryLight=Color(0xFFA5B4FC),primaryDark=Color(0xFF4F46E5);
  static const Color secondary=Color(0xFFEC4899),accent=Color(0xFF14B8A6);
  static const Color background=Color(0xFFF8FAFC),surface=Color(0xFFFFFFFF),surfaceVariant=Color(0xFFF1F5F9);
  static const Color error=Color(0xFFEF4444),success=Color(0xFF22C55E),warning=Color(0xFFF59E0B);
  static const Color textPrimary=Color(0xFF1E293B),textSecondary=Color(0xFF64748B),textHint=Color(0xFF94A3B8),divider=Color(0xFFE2E8F0);
  static const List<Color> courseColors=[Color(0xFF6366F1),Color(0xFFEC4899),Color(0xFF14B8A6),Color(0xFFF59E0B),Color(0xFF8B5CF6),Color(0xFF06B6D4),Color(0xFF84CC16),Color(0xFFEF4444),Color(0xFF3B82F6),Color(0xFFF97316),Color(0xFF22C55E),Color(0xFFA855F7)];
  static Color courseColor(int i)=>courseColors[i%courseColors.length];
  static const Color darkBackground=Color(0xFF0F172A),darkSurface=Color(0xFF1E293B),darkSurfaceVariant=Color(0xFF334155);
}
