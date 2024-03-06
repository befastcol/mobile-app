import 'dart:ui';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  FrameInfo fi = await codec.getNextFrame();
  final byteData = await fi.image.toByteData(format: ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}
