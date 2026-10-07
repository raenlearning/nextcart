import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class HeartBurstAnimation {
  HeartBurstAnimation._();

  static void burst({
    required BuildContext context,
    required GlobalKey key,
    Color color = AppColors.favorite,
  }) {
    final RenderBox? box =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;

    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    final center = Offset(
      position.dx + size.width / 2,
      position.dy + size.height / 2,
    );

    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _BurstOverlay(
        center: center,
        color: color,
        onCompleted: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _BurstOverlay extends StatefulWidget {
  final Offset center;
  final Color color;
  final VoidCallback onCompleted;

  const _BurstOverlay({
    required this.center,
    required this.color,
    required this.onCompleted,
  });

  @override
  State<_BurstOverlay> createState() => _BurstOverlayState();
}

class _BurstOverlayState extends State<_BurstOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onCompleted();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: widget.center.dx - 60,
          top: widget.center.dy - 60,
          child: SizedBox(
            width: 120,
            height: 120,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = Curves.easeOutCubic.transform(_controller.value);
                return CustomPaint(
                  painter: _BurstPainter(progress: t, color: widget.color),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _BurstPainter extends CustomPainter {
  final double progress;
  final Color color;

  _BurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (1 - progress) * 3
      ..color = color.withValues(alpha: (1 - progress) * 0.6);

    canvas.drawCircle(center, 12 + progress * 36, paintRing);

    const particleCount = 8;
    final paintDot = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: (1 - progress));

    for (var i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance = 14 + progress * 30;
      final dotCenter = center +
          Offset(math.cos(angle), math.sin(angle)) *
              distance *
              Curves.easeOut.transform(progress);
      final radius = (1 - progress) * 3.5;
      canvas.drawCircle(dotCenter, radius, paintDot);
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
