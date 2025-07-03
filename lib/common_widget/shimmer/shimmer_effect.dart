import 'package:flutter/material.dart';
import 'package:foodapp/ultils/const/color_extension.dart';

class TShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;
  final ShimmerDirection direction;
  final bool enabled;
  const TShimmer({
    Key? key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.duration = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.ltr,
    this.enabled = true,
  }) : super(key: key);
  factory TShimmer.color3({
    required Widget child,
    ShimmerDirection direction = ShimmerDirection.ltr,
    bool enabled = true,
  }) {
    return TShimmer(
      baseColor: TColor.gray,
      highlightColor: TColor.gray,
      direction: direction,
      enabled: enabled,
      child: child,
    );
  }
  factory TShimmer.dark({
    required Widget child,
    ShimmerDirection direction = ShimmerDirection.ltr,
    bool enabled = true,
  }) {
    return TShimmer(
      baseColor: Colors.grey[700]!,
      highlightColor: Colors.grey[600]!,
      direction: direction,
      enabled: enabled,
      child: child,
    );
  }

  @override
  State<TShimmer> createState() => _TShimmerState();
}

enum ShimmerDirection {
  ltr,
  rtl,
  ttb,
  btt,
}

class _TShimmerState extends State<TShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(TShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Gradient _getGradient() {
    switch (widget.direction) {
      case ShimmerDirection.ltr:
        return LinearGradient(
          colors: [
            widget.baseColor,
            widget.highlightColor,
            widget.baseColor,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: const Alignment(-1.0, -0.3),
          end: const Alignment(1.0, 0.3),
        );
      case ShimmerDirection.rtl:
        return LinearGradient(
          colors: [
            widget.baseColor,
            widget.highlightColor,
            widget.baseColor,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: const Alignment(1.0, -0.3),
          end: const Alignment(-1.0, 0.3),
        );
      case ShimmerDirection.ttb:
        return LinearGradient(
          colors: [
            widget.baseColor,
            widget.highlightColor,
            widget.baseColor,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: const Alignment(-0.3, -1.0),
          end: const Alignment(0.3, 1.0),
        );
      case ShimmerDirection.btt:
        return LinearGradient(
          colors: [
            widget.baseColor,
            widget.highlightColor,
            widget.baseColor,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: const Alignment(0.3, 1.0),
          end: const Alignment(-0.3, -1.0),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final Gradient gradient = _getGradient();
            Rect rect;
            if (widget.direction == ShimmerDirection.ltr ||
                widget.direction == ShimmerDirection.rtl) {
              rect = Rect.fromLTWH(
                -bounds.width + (_controller.value * bounds.width * 3),
                0,
                bounds.width * 3,
                bounds.height,
              );
            } else {
              rect = Rect.fromLTWH(
                0,
                -bounds.height + (_controller.value * bounds.height * 3),
                bounds.width,
                bounds.height * 3,
              );
            }

            return gradient.createShader(rect);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class TShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? color;

  const TShimmerBox({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

class TShimmerCircle extends StatelessWidget {
  final double size;
  final Color? color;

  const TShimmerCircle({
    Key? key,
    required this.size,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

