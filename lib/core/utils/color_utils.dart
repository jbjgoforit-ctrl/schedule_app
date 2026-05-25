import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
class ColorUtils {
  ColorUtils._();
  static Color parseHex(String hex){try{final c=int.parse(hex.replaceFirst('#','0xFF'));return Color(c);}catch(_){return AppColors.primary;}}
  static String toHex(Color c){return '#${c.toARGB32().toRadixString(16).padLeft(8,'0').substring(2)}';}
  static Color getByIndex(int i)=>AppColors.courseColor(i);
}
