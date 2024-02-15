import 'dart:io';

import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/models/location.dart';
import 'package:be_fast/screens/home/deliveries/delivery_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDeliveries extends StatefulWidget {
  final String userId, name;
  final LocationModel originLocation;

  const UserDeliveries(
      {super.key,
      required this.userId,
      required this.name,
      required this.originLocation});

  @override
  State<UserDeliveries> createState() => _UserDeliveriesState();
}

class _UserDeliveriesState extends State<UserDeliveries> {
  List<DeliveryModel> deliveries = [];
  bool isLoading = false;

  Future _handleGetUserDeliveries() async {
    setState(() => isLoading = true);
    try {
      deliveries =
          await DeliveriesAPI().getUserDeliveries(userId: widget.userId);
    } finally {
      if (mounted) {
        setState(() {
          setState(() => isLoading = false);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _handleGetUserDeliveries();
  }

  void _launchGoogleMaps() async {
    final latitude = widget.originLocation.coordinates[1];
    final longitude = widget.originLocation.coordinates[0];
    String googleMapsUrl;

    if (Platform.isAndroid) {
      googleMapsUrl = 'geo:$latitude,$longitude?q=$latitude,$longitude';
    } else if (Platform.isIOS) {
      googleMapsUrl =
          'comgooglemaps://?daddr=$latitude,$longitude&directionsmode=driving';
    } else {
      googleMapsUrl =
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';
    }

    final Uri uri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final Uri fallbackUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving');
      if (await canLaunchUrl(fallbackUri)) {
        await launchUrl(fallbackUri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deliveries.isEmpty ? Colors.white : Colors.grey[100],
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.amber,
        title: Text(widget.name),
        actions: widget.originLocation.coordinates.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.location_on),
                  onPressed: _launchGoogleMaps,
                ),
              ]
            : [],
      ),
      body: RefreshIndicator(
        onRefresh: _handleGetUserDeliveries,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : deliveries.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 180),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 50),
                          child: Image.asset('assets/empty.png')),
                      const Center(
                          child: Text(
                        'Usuario sin servicios',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      )),
                    ],
                  )
                : ListView.builder(
                    itemCount: deliveries.length,
                    itemBuilder: (context, index) {
                      final delivery = deliveries[index];
                      return DeliveryCard(
                        deliveyId: delivery.id,
                        status: delivery.status,
                        date: delivery.requestedDate,
                        destination: delivery.destination.title,
                        origin: delivery.origin.title,
                        price: delivery.price,
                      );
                    },
                  ),
      ),
    );
  }
}
