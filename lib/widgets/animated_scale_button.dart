import 'package:flutter/material.dart';

class AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final Function()? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Size? minimumSize;
  final IconData? icon;
  final Color? borderColor;
  final double? borderWidth;
  final BorderSide? side;

  const AnimatedScaleButton({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.minimumSize,
    this.icon,
    this.borderColor,
    this.borderWidth,
    this.side,
  });

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _controller;
  }

  void _onTapDown(_) => _controller.reverse();
  void _onTapUp(_) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: ElevatedButton.icon(
          onPressed: widget.onTap,
          icon: widget.icon != null
              ? Icon(widget.icon)
              : const SizedBox.shrink(),
          label: widget.child,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            minimumSize: widget.minimumSize,
            side:
                widget.side ??
                (widget.borderColor != null
                    ? BorderSide(
                        color: widget.borderColor!,
                        width: widget.borderWidth ?? 2.0,
                      )
                    : null),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }
}
