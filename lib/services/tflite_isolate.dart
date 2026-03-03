// tflite_flutter uses dart:ffi which is not available on web.
// We stub the service on web so the app compiles.
// Actual TFLite inference only runs on mobile/desktop.
export 'tflite_isolate_stub.dart' if (dart.library.ffi) 'tflite_isolate_native.dart';
