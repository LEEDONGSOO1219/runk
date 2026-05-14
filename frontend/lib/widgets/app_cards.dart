import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = _LocalColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.text,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = _LocalColors.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: colors.isDark ? 12 : 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = _LocalColors.of(context);

    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        color: colors.surfaceHigh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: colors.accent),
              const SizedBox(height: 14),
            ],
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.text,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.muted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapPreview extends StatelessWidget {
  const MapPreview({
    this.height = 150,
    this.label = '러닝 루트',
    super.key,
  });

  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = _LocalColors.of(context);
    final background = colors.isDark ? const Color(0xFF151920) : Colors.white;
    final gridColor =
        colors.isDark ? const Color(0xFF2B3038) : const Color(0xFFE6EAF0);
    final labelBackground =
        colors.isDark ? const Color(0xCC171A20) : const Color(0xF7FFFFFF);
    final glowColor =
        colors.isDark ? const Color(0x668DE0B4) : const Color(0x3320242B);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: background,
        border: Border.all(color: colors.line),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MapLinePainter(
                gridColor: gridColor,
                routeColor:
                    colors.isDark ? colors.green : const Color(0xFF20242B),
                glowColor: glowColor,
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: labelBackground,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: colors.line),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.near_me, size: 14, color: colors.accent),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colors.text,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLinePainter extends CustomPainter {
  const _MapLinePainter({
    required this.gridColor,
    required this.routeColor,
    required this.glowColor,
  });

  final Color gridColor;
  final Color routeColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var x = 18.0; x < size.width; x += 42) {
      canvas.drawLine(Offset(x, 0), Offset(x - 24, size.height), gridPaint);
    }
    for (var y = 18.0; y < size.height; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 16), gridPaint);
    }

    final glowPath = Path()
      ..moveTo(size.width * 0.16, size.height * 0.74)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.24,
        size.width * 0.50,
        size.height * 0.86,
        size.width * 0.65,
        size.height * 0.44,
      )
      ..cubicTo(
        size.width * 0.76,
        size.height * 0.12,
        size.width * 0.84,
        size.height * 0.46,
        size.width * 0.90,
        size.height * 0.20,
      );
    canvas.drawPath(
      glowPath,
      Paint()
        ..color = glowColor
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      glowPath,
      Paint()
        ..color = routeColor
        ..strokeWidth = 2.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LocalColors {
  const _LocalColors({
    required this.isDark,
    required this.surface,
    required this.surfaceHigh,
    required this.text,
    required this.muted,
    required this.line,
    required this.accent,
    required this.green,
    required this.shadow,
  });

  final bool isDark;
  final Color surface;
  final Color surfaceHigh;
  final Color text;
  final Color muted;
  final Color line;
  final Color accent;
  final Color green;
  final Color shadow;

  static _LocalColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _LocalColors(
      isDark: isDark,
      surface: isDark ? const Color(0xFF171A20) : Colors.white,
      surfaceHigh: isDark ? const Color(0xFF20242B) : const Color(0xFFF0F2F5),
      text: isDark ? const Color(0xFFF2F4F7) : const Color(0xFF111317),
      muted: isDark ? const Color(0xFF9AA3AF) : const Color(0xFF6B7280),
      line: isDark ? const Color(0xFF2A3038) : const Color(0xFFE0E4EA),
      accent: isDark ? const Color(0xFFD9E4F2) : const Color(0xFF111317),
      green: isDark ? const Color(0xFF7FD6A8) : const Color(0xFF128A55),
      shadow: isDark ? const Color(0x33000000) : const Color(0x160F172A),
    );
  }
}
