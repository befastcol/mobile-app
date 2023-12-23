import 'package:be_fast/screens/home/register/main.dart';
import 'package:be_fast/screens/home/orders/main.dart';
import 'package:be_fast/screens/home/profile/main.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late bool hasAdminAccess;
  late bool hasDeliveryAccess;

  @override
  void initState() {
    hasAdminAccess = false;
    hasDeliveryAccess = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.yellow[600],
              child: const Text(
                'E',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
            ),
            currentAccountPictureSize: const Size(60, 60),
            accountEmail: const Text('(312)312-3123'),
            accountName: const Text(
              'Eduardo',
              style: TextStyle(fontSize: 24.0),
            ),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(39, 50, 112, 1),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            trailing: const Icon(Icons.navigate_next),
            title: const Text('Mi perfil'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profile()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            trailing: const Icon(Icons.navigate_next),
            title: const Text('Mis pedidos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Orders()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            trailing: const Icon(Icons.navigate_next),
            title: const Text('Configuración'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          const Divider(),
          if (!hasDeliveryAccess && !hasAdminAccess)
            ListTile(
              leading: const Icon(Icons.motorcycle),
              trailing: const Icon(Icons.navigate_next),
              title: const Text('Quiero ser repartidor'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Register()),
                );
              },
            ),
          if (hasDeliveryAccess)
            ListTile(
              leading: const Icon(Icons.motorcycle),
              trailing: const Icon(Icons.navigate_next),
              title: const Text('Mis viajes'),
              onTap: () {
                // Acción al presionar
              },
            ),
          if (hasAdminAccess)
            ListTile(
              leading: const Icon(Icons.motorcycle),
              trailing: const Icon(Icons.navigate_next),
              title: const Text('Repartidores'),
              onTap: () {
                // Acción al presionar
              },
            ),
          if (hasAdminAccess)
            ListTile(
              leading: const Icon(Icons.people),
              trailing: const Icon(Icons.navigate_next),
              title: const Text('Usuarios'),
              onTap: () {
                // Acción al presionar
              },
            ),
        ],
      ),
    );
  }
}
