import 'package:be_fast/models/custom/custom.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryDetailsCard extends StatelessWidget {
  final String phone, name;
  final Point? origin, destination;
  final int price;

  const DeliveryDetailsCard(
      {super.key,
      required this.origin,
      required this.destination,
      required this.phone,
      required this.name,
      required this.price});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: SlidingUpPanel(
          defaultPanelState: PanelState.OPEN,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          panelBuilder: (ScrollController sc) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Icon(
                    Icons.drag_handle,
                    color: Colors.grey,
                    size: 30.0,
                  ),
                ),
                ListTile(
                  title: Text(name),
                  subtitle: Text("Costo del envío: \$$price"),
                  leading: const Icon(
                    Icons.person,
                    color: Colors.blueGrey,
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.phone,
                      color: Colors.teal,
                    ),
                    onPressed: () async {
                      final Uri launchUri = Uri(
                        scheme: 'tel',
                        path: phone,
                      );
                      if (await canLaunchUrl(launchUri)) {
                        await launchUrl(launchUri);
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text("${origin?.title}"),
                  subtitle: Text("${origin?.subtitle}"),
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: Text("${destination?.title}"),
                  subtitle: Text("${destination?.subtitle}"),
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            backgroundColor: Colors.red),
                        child: const Text('Cancelar servicio',
                            style: TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            ),
          ),
          minHeight: 100,
          maxHeight: 380,
          collapsed: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.drag_handle,
                color: Colors.grey,
                size: 30.0,
              ),
            ),
          ),
        ));
  }
}
