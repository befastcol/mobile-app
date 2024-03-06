import 'package:be_fast/providers/user.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/screens/location_selection_screen.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationItem extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final String text;
  final bool isSelectingOrigin, isDisabled;

  const LocationItem(
      {super.key,
      required this.iconData,
      required this.iconColor,
      required this.text,
      required this.isSelectingOrigin,
      required this.isDisabled});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        builder: (context, provider, child) => Material(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  if (!isDisabled) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationSelectionScreen(
                          isSelectingOrigin: isSelectingOrigin,
                          originTitle: provider.origin.title,
                          destinationTitle: provider.destination.title,
                        ),
                      ),
                    );
                  } else {
                    showSnackBar(context,
                        "No puedes crear más pedidos porque tu cuenta ha sido deshabilitada.");
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                  child: Row(
                    children: [
                      Icon(iconData, color: iconColor),
                      const SizedBox(width: 10),
                      Text(text),
                    ],
                  ),
                ),
              ),
            ));
  }
}
