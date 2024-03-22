import 'dart:async';

import 'package:be_fast/screens/home/courier/providers/courier_stream_provider.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServiceFoundCard extends StatefulWidget {
  const ServiceFoundCard({Key? key}) : super(key: key);

  @override
  State<ServiceFoundCard> createState() => _ServiceFoundCardState();
}

class _ServiceFoundCardState extends State<ServiceFoundCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourierStreamProvider>(
      builder: (context, streamState, child) {
        final timeLeft = streamState.deadline != null
            ? streamState.deadline!.difference(DateTime.now()).inSeconds
            : 0;

        return Visibility(
          visible: streamState.serviceFound && timeLeft > 0,
          child: Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Card(
              surfaceTintColor: Colors.white,
              color: Colors.white,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
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
                      visible: !streamState.isAcceptingService,
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                try {
                                  await streamState.acceptService(context, () {
                                    if (mounted) {
                                      showSnackBar(context,
                                          "Pedido cancelado por el usuario.");
                                    }
                                  });
                                } catch (e) {
                                  if (mounted) {
                                    showSnackBar(context,
                                        "Error al aceptar el servicio.");
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text('Aceptar',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('$timeLeft segundos restantes',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.blueGrey)),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: streamState.isAcceptingService,
                      child: Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: const Center(
                          child: LinearProgressIndicator(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.blue,
                            minHeight: 50,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
