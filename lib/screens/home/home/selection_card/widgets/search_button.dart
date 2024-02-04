import 'package:flutter/material.dart';

class SearchButtonWidget extends StatelessWidget {
  const SearchButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.blue,
        ),
        child: const Text('Buscar repartidores',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
