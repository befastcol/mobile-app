import 'package:be_fast/providers/user.dart';
import 'package:be_fast/screens/home/courier_requests/main.dart';
import 'package:be_fast/screens/home/couriers/main.dart';
import 'package:be_fast/screens/home/users/main.dart';
import 'package:be_fast/utils/phone_number_format.dart';
import 'package:flutter/material.dart';
import 'package:be_fast/utils/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:be_fast/screens/home/register/main.dart';
import 'package:be_fast/screens/home/deliveries/main.dart';
import 'package:be_fast/screens/home/profile/main.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    void updateUserName(String name) async {
      ref.read(userProvider.notifier).updateUserName(name);
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text(formatPhoneNumber(user?.phone)),
            accountName: Text(
              user?.name ?? '',
              style: const TextStyle(fontSize: 24.0),
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
                MaterialPageRoute(
                    builder: (context) => Profile(
                          userId: user?.id,
                          name: user?.name,
                          updateUserName: updateUserName,
                        )),
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
                MaterialPageRoute(builder: (context) => const Deliveries()),
              );
            },
          ),
          const Divider(),
          Visibility(
            visible: user?.role == 'user',
            child: ListTile(
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
          ),
          Visibility(
            visible: user?.role == 'courier',
            child: ListTile(
              leading: const Icon(Icons.motorcycle),
              trailing: const Icon(Icons.navigate_next),
              title: const Text('Mis viajes'),
              onTap: () {
                // Acción al presionar
              },
            ),
          ),
          Visibility(
            visible: user?.role == 'admin',
            child: ListTile(
              leading: const Icon(Icons.motorcycle),
              trailing: const Icon(Icons.navigate_next),
              title: const Text('Repartidores'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Couriers()),
                );
              },
            ),
          ),
          Visibility(
            visible: user?.role == 'admin',
            child: ListTile(
              leading: const Icon(Icons.people),
              trailing: const Icon(Icons.navigate_next),
              title: const Text('Usuarios'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Users()),
                );
              },
            ),
          ),
          Visibility(
            visible: user?.role == 'admin',
            child: ListTile(
              leading: const Icon(Icons.insert_drive_file_sharp),
              trailing: const Icon(Icons.navigate_next),
              title: const Text('Solicitudes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CourierRequests()),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              AuthService.logout();
            },
          ),
        ],
      ),
    );
  }
}
