import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/memory.dart';
import '../../../core/constants/app_colors.dart';

/// A timeline node representing a specific memory or journey stop.
/// Uses a custom painter to draw elegant curving connected lines.
class JourneyTimelineNode extends StatelessWidget {
  final Memory memory;
  final bool isLastNode;
  final bool isFirstNode;
  final bool alignLeft; // Alternate layout for human-touch visual interest

  const JourneyTimelineNode({
    super.key,
    required this.memory,
    this.isLastNode = false,
    this.isFirstNode = false,
    this.alignLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Content Left
          if (alignLeft) Expanded(child: _buildCard()),
          
          // Center Timeline Line & Dot
          SizedBox(
            width: 60, // Increased width to accommodate hanging hooks
            child: CustomPaint(
              painter: _CurvedTimelinePainter(
                isLast: isLastNode,
                isFirst: isFirstNode,
                curvesRight: alignLeft, 
              ),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 18,
                  width: 18,
                  decoration: BoxDecoration(
                    color: AppColors.terracotta,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.warmSand, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.terracotta.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Content Right
          if (!alignLeft) Expanded(child: _buildCard()),
        ],
      ),
    );
  }

  /// Builds the elegant memory card, acting like a hanging polaroid
  Widget _buildCard() {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display Image if it exists
          if (memory.imagePath != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.file(
                File(memory.imagePath!),
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          
          // Text Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(memory.date),
                  style: const TextStyle(
                    color: AppColors.terracotta,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                if (memory.title.isNotEmpty)
                  Text(
                    memory.title,
                    style: const TextStyle(
                      color: AppColors.deepNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                if (memory.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    memory.description,
                    style: TextStyle(
                      color: AppColors.deepNavy.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter to draw a beautiful continuous curved path for the timeline,
/// including small horizontal lines connecting the dot to the card.
class _CurvedTimelinePainter extends CustomPainter {
  final bool isLast;
  final bool isFirst;
  final bool curvesRight;

  _CurvedTimelinePainter({
    required this.isLast,
    required this.isFirst,
    required this.curvesRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = AppColors.terracotta.withOpacity(0.4)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // Draw main timeline path
    if (isFirst) {
      path.moveTo(centerX, centerY);
    } else {
      path.moveTo(centerX, 0);
      final double cpX1 = curvesRight ? size.width * 0.8 : size.width * 0.2;
      path.quadraticBezierTo(cpX1, centerY / 2, centerX, centerY);
    }

    if (!isLast) {
      final double cpX2 = !curvesRight ? size.width * 0.8 : size.width * 0.2;
      path.quadraticBezierTo(cpX2, centerY + (size.height - centerY) / 2, centerX, size.height);
    }
    
    canvas.drawPath(path, linePaint);

    // Draw horizontal "hanging" connector line to the card
    final connectorPath = Path();
    connectorPath.moveTo(centerX, centerY);
    if (curvesRight) {
      connectorPath.lineTo(0, centerY); // Connects to left card
    } else {
      connectorPath.lineTo(size.width, centerY); // Connects to right card
    }
    
    final Paint connectorPaint = Paint()
      ..color = AppColors.terracotta.withOpacity(0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(connectorPath, connectorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}