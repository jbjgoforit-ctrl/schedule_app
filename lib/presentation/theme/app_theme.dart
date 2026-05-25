import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
class AppTheme {
  AppTheme._();
  static ThemeData get lightTheme => ThemeData(useMaterial3:true,brightness:Brightness.light,colorSchemeSeed:AppColors.primary,scaffoldBackgroundColor:AppColors.background,appBarTheme:const AppBarTheme(centerTitle:true,elevation:0,scrolledUnderElevation:1,backgroundColor:AppColors.surface,foregroundColor:AppColors.textPrimary),cardTheme:CardThemeData(elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),color:AppColors.surface));
  static ThemeData get darkTheme => ThemeData(useMaterial3:true,brightness:Brightness.dark,colorSchemeSeed:AppColors.primary,scaffoldBackgroundColor:AppColors.darkBackground,appBarTheme:AppBarTheme(centerTitle:true,elevation:0,scrolledUnderElevation:1,backgroundColor:AppColors.darkSurface,foregroundColor:Colors.white),cardTheme:CardThemeData(elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),color:AppColors.darkSurface));
}
