import 'package:be_fast/providers/user.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/widgets/location_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OriginLocation extends StatelessWidget {
  const OriginLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        builder: (context, provider, child) => Visibility(
              visible: provider.destination.coordinates.isNotEmpty,
              child: Column(
                children: [
                  LocationItem(
                    isDisabled: false,
                    isSelectingOrigin: true,
                    iconData: Icons.location_on,
                    iconColor: Colors.blue,
                    text: provider.origin.title,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ));
  }
}
