import 'package:flutter/material.dart';

final GlobalKey cartIconKey = GlobalKey();

final ValueNotifier<int> cartBumpNotifier = ValueNotifier<int>(0);

class CartFlyAnimation {
  CartFlyAnimation._();

  static void fly({
    required BuildContext context,
    required GlobalKey startKey,
    IconData icon = Icons.shopping_bag,
    Color color = Colors.white,
    required Color backgroundColor,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);

    final startBox = startKey.currentContext?.findRenderObject() as RenderBox?;
    if (startBox == null) return;

    final startOffset = startBox.localToGlobal(
      startBox.size.center(Offset.zero),
    );

    final cartBox =
        cartIconKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset endOffset;
    if (cartBox != null && cartBox.attached) {
      endOffset = cartBox.localToGlobal(cartBox.size.center(Offset.zero));
    } else {
      final screenSize = MediaQuery.of(context).size;
      endOffset = Offset(
        screenSize.width - 36,
        MediaQuery.of(context).padding.top + 50,
      );
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FlyingIcon(
        start: startOffset,
        end: endOffset,
        icon: icon,
        color: color,
        backgroundColor: backgroundColor,
        onCompleted: () {
          entry.remove();
          cartBumpNotifier.value++;
        },
      ),
    );

    overlay.insert(entry);
  }
}

class _FlyingIcon extends StatefulWidget {
  final Offset start;
  final Offset end;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onCompleted;

  const _FlyingIcon({
    required this.start,
    required this.end,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onCompleted,
  });

  @override
  State<_FlyingIcon> createState() => _FlyingIconState();
}

class _FlyingIconState extends State<_FlyingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInCubic);

    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.3), weight: 75),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _controller.forward().whenComplete(widget.onCompleted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _arcPosition(double t) {
    final controlPoint = Offset(
      (widget.start.dx + widget.end.dx) / 2,
      widget.start.dy - 140,
    );

    final oneMinusT = 1 - t;
    final dx =
        oneMinusT * oneMinusT * widget.start.dx +
        2 * oneMinusT * t * controlPoint.dx +
        t * t * widget.end.dx;
    final dy =
        oneMinusT * oneMinusT * widget.start.dy +
        2 * oneMinusT * t * controlPoint.dy +
        t * t * widget.end.dy;

    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final position = _arcPosition(_progress.value);
        return Positioned(
          left: position.dx - 18,
          top: position.dy - 18,
          child: Opacity(
            opacity: 1 - _fade.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.backgroundColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: widget.color, size: 18),
              ),
            ),
          ),
        );
      },
    );
  }
}
