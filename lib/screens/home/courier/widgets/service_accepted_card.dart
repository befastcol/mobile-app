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
      builder: (context, provider, child) {
        return Visibility(
          visible: provider.serviceAccepted,
          child: SlidingUpPanel(
            defaultPanelState: PanelState.CLOSED,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            panelBuilder: (ScrollController sc) => _buildPanel(sc, provider),
            minHeight: 100,
            maxHeight: 350,
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

  Widget _buildPanel(ScrollController sc, CourierStreamProvider provider) {
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
            title: Text("${provider.delivery?.origin.title}"),
            subtitle: Text("${provider.delivery?.origin.subtitle}"),
            leading: const Icon(
              Icons.location_on,
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text("${provider.delivery?.destination.title}"),
            subtitle: Text("${provider.delivery?.destination.subtitle}"),
            leading: const Icon(
              Icons.location_on,
              color: Colors.red,
            ),
          ),
          ListTile(
            title: Text("\$${provider.delivery?.price} MXN"),
            leading: const Icon(
              Icons.payments,
              color: Colors.teal,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  //TODO: End service
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    backgroundColor: Colors.teal),
                child: const Text('Terminar servicio',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
