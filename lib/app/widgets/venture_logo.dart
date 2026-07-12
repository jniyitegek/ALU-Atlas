import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class VentureLogo extends StatelessWidget {
  final String? logoUrl;
  final String? name;
  final double size;
  final BoxShape shape;
  final Color? backgroundColor;

  const VentureLogo({
    super.key,
    required this.logoUrl,
    this.name,
    this.size = 48,
    this.shape = BoxShape.circle,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        color: backgroundColor ?? AppColors.primary.withOpacity(0.08),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final path = logoUrl ?? '';
    if (path.isEmpty) return _fallback();

    if (path.startsWith('/') || path.contains('content://')) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover, width: size, height: size,
            errorBuilder: (_, __, ___) => _fallback());
      }
      return _fallback();
    }

    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover, width: size, height: size,
          errorBuilder: (_, __, ___) => _fallback());
    }

    return Center(child: Text(path, style: TextStyle(fontSize: size * 0.48)));
  }

  Widget _fallback() {
    if (name == null || name!.isEmpty) {
      return Center(
        child: Icon(
          Icons.business,
          color: AppColors.primary,
          size: size * 0.55,
        ),
      );
    }
    final label = name![0].toUpperCase();
    return Center(
      child: Text(label,
          style: TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          )),
    );
  }
}
