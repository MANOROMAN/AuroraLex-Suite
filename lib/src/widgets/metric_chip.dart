import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class MetricChip extends StatelessWidget {
  const MetricChip({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accentColor = AuroraColors.aurora,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 18, color: accentColor),
          if (icon != null) const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.4,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
