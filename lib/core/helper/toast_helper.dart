import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

enum ToastSeverity { success, error, warning, info }

class ToastHelper {
  ToastHelper._();

  static void showTopToast(BuildContext context, String message, {Duration? duration}) {
    showToast(context, message, ToastSeverity.success, duration: duration);
  }

  static void showToast(
    BuildContext context,
    String message,
    ToastSeverity severity, {
    Duration? duration,
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _AnimatedToast(
        entry: overlayEntry,
        message: message,
        severity: severity,
        duration: duration ?? const Duration(seconds: 2),
        onDismissed: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _AnimatedToast extends StatefulWidget {
  final OverlayEntry entry;
  final String message;
  final ToastSeverity severity;
  final Duration duration;
  final VoidCallback onDismissed;

  const _AnimatedToast({
    required this.entry,
    required this.message,
    required this.severity,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    reverseDuration: const Duration(milliseconds: 200),
  );

  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, -1.5),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  late final Animation<double> _fadeAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().whenCompleteOrCancel(widget.onDismissed);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  (Color, IconData) get _severityStyle {
    switch (widget.severity) {
      case ToastSeverity.success:
        return (AppColors.success, Icons.check_circle_rounded);
      case ToastSeverity.error:
        return (AppColors.error, Icons.cancel_rounded);
      case ToastSeverity.warning:
        return (AppColors.warning, Icons.warning_amber_rounded);
      case ToastSeverity.info:
        return (AppColors.primary, Icons.info_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (tint, icon) = _severityStyle;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.textPrimary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
                border: Border.all(color: colors.border.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: tint, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
