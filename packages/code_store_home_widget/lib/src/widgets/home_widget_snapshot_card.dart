import 'package:flutter/material.dart';
import '../models/home_widget_payload.dart';

/// A sleek pre-styled card designed to be rendered offscreen and displayed inside native Home Screen widgets.
class HomeWidgetSnapshotCard extends StatelessWidget {
  const HomeWidgetSnapshotCard({
    super.key,
    required this.payload,
    this.backgroundColor = const Color(0xFF1E1E2E),
    this.accentColor = const Color(0xFF7C4DFF),
    this.textColor = Colors.white,
    this.subtitleColor = const Color(0xFFA6ADC8),
  });

  final HomeWidgetPayload payload;
  final Color backgroundColor;
  final Color accentColor;
  final Color textColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.widgets_rounded,
                      size: 16,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    payload.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (payload.status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payload.status!,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            payload.message,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 13,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payload.updatedAt != null
                    ? 'Updated ${_formatTime(payload.updatedAt!)}'
                    : 'Just now',
                style: TextStyle(
                  color: subtitleColor.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
              if (payload.badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${payload.badgeCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
