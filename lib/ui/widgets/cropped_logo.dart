import 'package:flutter/material.dart';

class CroppedLogo extends StatelessWidget {
  final double width;

  const CroppedLogo({
    Key? key,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 662x775 aspect ratio
    final double aspectRatio = 662.0 / 775.0;
    final double height = width / aspectRatio;

    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
