import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text('Configuración'),
      ),
      body: ListView(children: [
        ListTile(
          trailing: const Icon(Icons.navigate_next),
          title: const Text('Cobro de cada pedido'),
          leading: const Icon(Icons.account_box),
          onTap: () {},
        ),
        ListTile(
          trailing: const Icon(Icons.navigate_next),
          title: const Text('Cobro por cada viaje'),
          leading: const Icon(Icons.motorcycle),
          onTap: () {},
        ),
        ListTile(
          trailing: const Icon(Icons.navigate_next),
          title: const Text('Tarifa de lluvia'),
          leading: const Icon(Icons.monetization_on_outlined),
          onTap: () {},
        ),
        ListTile(
          trailing: const Icon(Icons.navigate_next),
          title: const Text('Administradores'),
          leading: const Icon(Icons.add_moderator_outlined),
          onTap: () {},
        ),
      ]),
    );
  }
}
