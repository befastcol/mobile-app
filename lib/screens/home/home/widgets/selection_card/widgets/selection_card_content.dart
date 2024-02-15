import 'package:be_fast/providers/user.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/widgets/destination_location.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/widgets/loading_skeleton.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/widgets/origin_location.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/widgets/search_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectionCardContent extends StatelessWidget {
  const SelectionCardContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        builder: (context, provider, value) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                    visible: provider.isUpdatingLocation,
                    child: const LoadingSkeleton()),
                Visibility(
                    visible: !provider.isUpdatingLocation,
                    child: const Column(
                      children: [
                        OriginLocation(),
                        DestinationLocation(),
                        SearchButtonWidget(),
                      ],
                    ))
              ],
            ));
  }
}
