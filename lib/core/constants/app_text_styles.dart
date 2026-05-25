import 'package:flutter/material.dart';
import 'app_colors.dart';
class AppTextStyles {
  AppTextStyles._();
  static const heading1=TextStyle(fontSize:28,fontWeight:FontWeight.bold,color:AppColors.textPrimary);
  static const heading2=TextStyle(fontSize:22,fontWeight:FontWeight.w600,color:AppColors.textPrimary);
  static const heading3=TextStyle(fontSize:18,fontWeight:FontWeight.w600,color:AppColors.textPrimary);
  static const body=TextStyle(fontSize:15,color:AppColors.textSecondary);
  static const bodySmall=TextStyle(fontSize:13,color:AppColors.textSecondary);
  static const caption=TextStyle(fontSize:12,color:AppColors.textHint);
  static const courseTitle=TextStyle(fontSize:13,fontWeight:FontWeight.w600,color:Colors.white);
  static const courseInfo=TextStyle(fontSize:11,color:Colors.white70);
}
