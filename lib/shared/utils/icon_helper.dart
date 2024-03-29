import 'package:be_fast/shared/utils/icons_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> getVehicleIcon(String vehicle,
    {int size = 100}) async {
  BitmapDescriptor icon;

  switch (vehicle) {
    case 'motorcycle':
      icon = await getBytesFromAsset("assets/images/moto_icon.png", size);
      break;
    case 'car':
      icon = await getBytesFromAsset("assets/images/car_icon.png", size);
      break;
    default:
      icon = await getBytesFromAsset("assets/images/moto_icon.png", size);
      break;
  }
  return icon;
}
