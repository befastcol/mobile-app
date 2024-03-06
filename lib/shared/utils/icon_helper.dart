import 'package:be_fast/shared/utils/bytes_from_asset.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getVehicleIcon(String vehicle) async {
  BitmapDescriptor icon;

  switch (vehicle) {
    case 'motorcycle':
      icon = await getBytesFromAsset("assets/images/moto_icon.png", 100);
      break;
    case 'car':
      icon = await getBytesFromAsset("assets/images/car_icon.png", 100);
      break;
    default:
      icon = await getBytesFromAsset("assets/images/moto_icon.png", 100);
      break;
  }
  return icon;
}
