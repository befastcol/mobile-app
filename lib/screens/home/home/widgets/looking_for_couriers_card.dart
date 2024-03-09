import 'package:be_fast/providers/delivery_provider.dart';
import 'package:be_fast/providers/user_map_provider.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:be_fast/shared/utils/socket_service.dart';
import 'package:be_fast/shared/widgets/delivery_map_location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LookingForCouriersCard extends StatefulWidget {
  const LookingForCouriersCard({super.key});

  @override
  State<LookingForCouriersCard> createState() => _LookingForCouriersCardState();
}

class _LookingForCouriersCardState extends State<LookingForCouriersCard> {
  final SocketService _socketService = SocketService();
  bool isCancelingService = false;

  @override
  void initState() {
    _socketService.initSocket();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeliveryProvider deliveryState =
          Provider.of<DeliveryProvider>(context, listen: false);
      UserMapProvider userMapState =
          Provider.of<UserMapProvider>(context, listen: false);
      _listenToDeliveryChanges(deliveryState, userMapState);
    });
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("looking for couriers disposed");
    _socketService.clearListeners();
    _socketService.disconnect();
    super.dispose();
  }

  void _listenToDeliveryChanges(
      DeliveryProvider deliveryState, UserMapProvider userMapState) {
    _socketService.emit("joinDeliveryRoom", {"deliveryId": deliveryState.id});
    _socketService.on("serviceAccepted", (data) {
      if (data['status'] == 'in_progress') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DeliveryMapLocation(
                    deliveryId: deliveryState.id,
                  )),
        ).then((value) {
          deliveryState.resetValues();
          userMapState.resetValues();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(builder: (context, deliveryState, child) {
      Future cancelService() async {
        try {
          setState(() => isCancelingService = true);
          await deliveryState.cancelDelivery(
            onSuccess: () {
              if (mounted) {
                showSnackBar(context, "Servicio cancelado");
                deliveryState.resetId();
              }
            },
            onError: (String errorMessage) {
              if (mounted) {
                showSnackBar(context, "Error al cancelar el servicio");
              }
            },
          );
        } finally {
          setState(() => isCancelingService = false);
        }
      }

      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Card(
          surfaceTintColor: Colors.white,
          margin: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  isCancelingService
                      ? 'Cancelando servicio...'
                      : 'Buscando repartidores...',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.symmetric(vertical: 26),
                    child: CircularProgressIndicator(
                      color: !isCancelingService ? Colors.blueGrey : Colors.red,
                    )),
                Visibility(
                  visible: !isCancelingService,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: cancelService,
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          backgroundColor: Colors.red),
                      child: const Text('Cancelar servicio',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
