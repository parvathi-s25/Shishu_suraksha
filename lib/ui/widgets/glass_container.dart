import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final double blurEffect;

  const GlassContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.blurEffect = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor.withAlpha(230),
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
