import 'package:be_fast/providers/map_provider.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/widgets/destination_location.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/widgets/loading_skeleton.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/widgets/origin_location.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/widgets/price_widget.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/widgets/search_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectionCardContent extends StatelessWidget {
  const SelectionCardContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
        builder: (context, mapProvider, value) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                    visible: mapProvider.isUpdatingLocation,
                    child: const LoadingSkeleton()),
                Visibility(
                    visible: !mapProvider.isUpdatingLocation,
                    child: const Column(
                      children: [
                        OriginLocation(),
                        DestinationLocation(),
                        PriceWidget(),
                        SearchButtonWidget(),
                      ],
                    ))
              ],
            ));
  }
}
