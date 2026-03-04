import 'dart:typed_data';

import 'package:flutter/foundation.dart';

// tflite_flutter uses dart:ffi which is not available on web.
// We stub the service on web so the app compiles.
// Actual TFLite inference only runs on mobile/desktop.
export 'tflite_service_stub.dart' if (dart.library.ffi) 'tflite_service_native.dart';
