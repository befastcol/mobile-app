import 'package:be_fast/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:be_fast/utils/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:be_fast/screens/home/register/main.dart';
import 'package:be_fast/screens/home/deliveries/main.dart';
import 'package:be_fast/screens/home/profile/main.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  String formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.length < 10) {
      return '';
    }
    String areaCode = phoneNumber.substring(0, 3);
    String middlePart = phoneNumber.substring(3, 6);
    String lastPart = phoneNumber.substring(6, 10);

    return '($areaCode) $middlePart-$lastPart';
  }

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
          if (user?.role == 'user')
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
          if (user?.role == 'courier')
            ListTile(
              leading: const Icon(Icons.motorcycle),
              trailing: const Icon(Icons.navigate_next),
              title: const Text('Mis viajes'),
              onTap: () {
                // Acción al presionar
              },
            ),
          if (user?.role == 'admin')
            ListTile(
              leading: const Icon(Icons.motorcycle),
              trailing: const Icon(Icons.navigate_next),
              title: const Text('Repartidores'),
              onTap: () {
                // Acción al presionar
              },
            ),
          if (user?.role == 'admin')
            ListTile(
              leading: const Icon(Icons.people),
              trailing: const Icon(Icons.navigate_next),
              title: const Text('Usuarios'),
              onTap: () {
                // Acción al presionar
              },
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
