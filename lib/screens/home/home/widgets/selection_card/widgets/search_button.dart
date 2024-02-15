import 'package:be_fast/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchButtonWidget extends StatelessWidget {
  const SearchButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return Visibility(
          visible: provider.origin.coordinates.isNotEmpty &&
              provider.destination.coordinates.isNotEmpty,
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.createDelivery,
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    backgroundColor: Colors.blue),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Solicitar servicio',
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(
                      width: 20,
                    ),
                    Visibility(
                      visible: provider.price > 0,
                      child: Text(
                        '\$${provider.price}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    )
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
