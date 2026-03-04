import 'package:flutter_test/flutter_test.dart';
import 'package:shishu_suraksha/utils/vision_utils.dart';
import 'dart:ui';

void main() {
  test('computeEyeSymmetry returns 0 for symmetric points', () {
    final left = Offset(100, 50);
    final right = Offset(140, 50);
    final sym = computeEyeSymmetry(left, right);
    expect(sym, closeTo((40).abs() / 40, 1e-6));
  });

  test('computeEyeSymmetry handles zero interocular', () {
    final p = Offset(100, 50);
    final sym = computeEyeSymmetry(p, p);
    expect(sym, double.infinity);
  });

  test('computeFaceRatio computes ratio', () {
    final ratio = computeFaceRatio(100, 400);
    expect(ratio, closeTo(0.25, 1e-6));
  });
}
