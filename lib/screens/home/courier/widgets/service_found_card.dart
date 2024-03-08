import 'package:be_fast/screens/home/courier/providers/courier_stream_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServiceFoundCard extends StatelessWidget {
  const ServiceFoundCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CourierStreamProvider>(
        builder: (context, provider, child) => Visibility(
              visible: provider.serviceFound,
              child: Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Card(
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  margin: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            "${provider.delivery?.origin.title}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            "${provider.delivery?.origin.subtitle}",
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
                            "${provider.delivery?.destination.title}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            "${provider.delivery?.destination.subtitle}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                                provider.acceptService(context);
                              },
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  backgroundColor: Colors.blue),
                              child: const Text('Aceptar',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }
}
