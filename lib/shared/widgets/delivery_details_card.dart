import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/models/custom/custom.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryDetailsCard extends StatefulWidget {
  final String phone, name;
  final String? id;
  final Point? origin, destination;
  final int price;

  const DeliveryDetailsCard(
      {super.key,
      required this.id,
      required this.origin,
      required this.destination,
      required this.phone,
      required this.name,
      required this.price});

  @override
  State<DeliveryDetailsCard> createState() => _DeliveryDetailsCardState();
}

class _DeliveryDetailsCardState extends State<DeliveryDetailsCard> {
  bool _isCancelingService = false;

  Future _cancelService() async {
    try {
      setState(() => _isCancelingService = true);
      await DeliveriesAPI.cancelDelivery(deliveryId: widget.id);
      if (mounted) {
        showSnackBar(context, "Servicio cancelado.");
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) showSnackBar(context, "Error al cancelar el servicio.");
    } finally {
      setState(() => _isCancelingService = false);
    }
  }

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
                  title: Text(widget.name),
                  subtitle: Text("Costo del envío: \$${widget.price}"),
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
                        path: widget.phone,
                      );
                      if (await canLaunchUrl(launchUri)) {
                        await launchUrl(launchUri);
                      }
                    },
                  ),
                ),
                ListTile(
                  title: Text(
                    "${widget.origin?.title}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "${widget.origin?.subtitle}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: Text(
                    "${widget.destination?.title}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "${widget.destination?.subtitle}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  leading: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                ),
                Visibility(
                  visible: !_isCancelingService,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: _cancelService,
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              backgroundColor: Colors.red),
                          child: const Text('Cancelar servicio',
                              style: TextStyle(color: Colors.white))),
                    ),
                  ),
                ),
                Visibility(
                  visible: _isCancelingService,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: const Center(
                      child: LinearProgressIndicator(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.red,
                        minHeight: 50,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          minHeight: 100,
          maxHeight: 390,
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
