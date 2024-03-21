import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:be_fast/screens/home/courier/providers/courier_stream_provider.dart';

class ServiceAcceptedCard extends StatefulWidget {
  const ServiceAcceptedCard({Key? key}) : super(key: key);

  @override
  State<ServiceAcceptedCard> createState() => _ServiceAcceptedCardState();
}

class _ServiceAcceptedCardState extends State<ServiceAcceptedCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CourierStreamProvider>(
      builder: (context, streamState, child) {
        return Visibility(
          visible: streamState.serviceAccepted,
          child: SlidingUpPanel(
            defaultPanelState: PanelState.CLOSED,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            panelBuilder: (ScrollController sc) => _buildPanel(sc, streamState),
            minHeight: 100,
            maxHeight: 360,
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
          ),
        );
      },
    );
  }

  Widget _buildPanel(ScrollController sc, CourierStreamProvider streamState) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Center(
            child: Icon(
              Icons.drag_handle,
              color: Colors.grey,
              size: 30.0,
            ),
          ),
          ListTile(
            title: Text(
              "${streamState.delivery?.origin.title}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "${streamState.delivery?.origin.subtitle}",
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
              "${streamState.delivery?.destination.title}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              "${streamState.delivery?.destination.subtitle}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading: const Icon(
              Icons.location_on,
              color: Colors.red,
            ),
          ),
          ListTile(
            title: Text("\$${streamState.delivery?.price} MXN"),
            leading: const Icon(
              Icons.payments,
              color: Colors.teal,
            ),
          ),
          Visibility(
            visible: !streamState.isEndingService,
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await streamState.endService();
                      if (mounted) {
                        showSnackBar(
                            context, "¡Servicio finalizando correctamente!");
                      }
                    } catch (e) {
                      if (mounted) {
                        showSnackBar(context, "Error finalizando el servicio");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.teal),
                  child: const Text('Finalizar servicio',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ),
          Visibility(
              visible: streamState.isEndingService,
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                child: const Center(
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.teal,
                    minHeight: 50,
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
