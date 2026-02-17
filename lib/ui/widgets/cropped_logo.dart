import 'package:flutter/material.dart';

class CroppedLogo extends StatelessWidget {
  final double width;

  const CroppedLogo({
    Key? key,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Enforce 662:775 aspect ratio
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: 662 / 775,
        child: ClipRect(
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover, // Crops the image to fill the aspect ratio
            alignment: Alignment.center, // Focus on center
          ),
        ),
      ),
    );
  }
}
