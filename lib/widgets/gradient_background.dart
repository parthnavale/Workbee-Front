import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;

  const GradientBackground({
    super.key,
    required this.child,
    this.padding,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.backgroundPrimary, AppColors.backgroundSecondary],
          begin: begin!,
          end: end!,
        ),
      ),
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
  }
} 