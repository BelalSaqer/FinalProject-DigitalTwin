import 'dart:ui';
import 'package:flutter/material.dart';
import 'dt_colors.dart';

PreferredSizeWidget appHeader({
  required String title,
  String? subtitle,
  Widget? leading,
  Widget? trailing,
}) {
  return AppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: 92,
    elevation: 0,
    backgroundColor: Colors.transparent,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DT.headerB, DT.headerA, DT.blue.alphaF(0.10)],
        ),
      ),
    ),
    titleSpacing: 18,
    title: Row(
      children: [
        if (leading != null) ...[
          leading,
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: DT.muted(0.55), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: DT.surface(0.22),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: DT.border(0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.alphaF(0.30),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: DT.grad,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: DT.blue.alphaF(0.28), blurRadius: 22, offset: const Offset(0, 12))],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
              ],
              Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}