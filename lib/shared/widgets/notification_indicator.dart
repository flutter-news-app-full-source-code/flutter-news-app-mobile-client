import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// {@template notification_indicator}
/// A widget that displays a small dot over its child to indicate a notification.
///
/// This is typically used to wrap a user avatar or an icon button.
/// {@endtemplate}
class NotificationIndicator extends StatefulWidget {
  /// {@macro notification_indicator}
  const NotificationIndicator({
    required this.child,
    required this.showIndicator,
    this.top,
    this.bottom,
    this.start,
    this.end,
    super.key,
  });

  /// The widget to display below the indicator.
  final Widget child;

  /// Whether to show the notification dot.
  final bool showIndicator;

  /// Optional top offset.
  final double? top;

  /// Optional bottom offset.
  final double? bottom;

  /// Optional start offset.
  final double? start;

  /// Optional end offset.
  final double? end;

  @override
  State<NotificationIndicator> createState() => _NotificationIndicatorState();
}

class _NotificationIndicatorState extends State<NotificationIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (widget.showIndicator) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NotificationIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showIndicator && !oldWidget.showIndicator) {
      _controller.repeat(reverse: true);
    } else if (!widget.showIndicator && oldWidget.showIndicator) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (widget.showIndicator)
          Positioned.directional(
            textDirection: Directionality.of(context),
            top: widget.bottom == null ? (widget.top ?? 2) : widget.top,
            bottom: widget.bottom,
            start: widget.start,
            end: widget.start == null ? (widget.end ?? 2) : widget.end,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Container(
                width: AppSpacing.sm,
                height: AppSpacing.sm,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
