import 'package:flutter/material.dart';

import '../utils/priority_helper.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const PriorityBadge({
    super.key,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final color = PriorityHelper.getColor(priority);
    final label = PriorityHelper.getLabel(priority);
    final icon = PriorityHelper.getIcon(priority);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
