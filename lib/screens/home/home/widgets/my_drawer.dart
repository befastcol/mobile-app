import "package:be_fast/providers/user_provider.dart";
import "package:be_fast/screens/home/courier/courier_map.dart";
import "package:be_fast/screens/home/couriers/couriers.dart";
import "package:be_fast/screens/home/deliveries/deliveries.dart";
import "package:be_fast/screens/home/location/location.dart";
import "package:be_fast/screens/home/profile/profile.dart";
import "package:be_fast/screens/home/register/register.dart";
import "package:be_fast/screens/home/requests/requests.dart";
import "package:be_fast/screens/home/settings/settings.dart";
import "package:be_fast/screens/home/trips/trips.dart";
import "package:be_fast/screens/home/users/users.dart";
import "package:be_fast/screens/home/vehicle/vehicle.dart";
import "package:be_fast/shared/utils/format_phone.dart";
import "package:be_fast/shared/utils/show_snack_bar.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        builder: (context, userState, child) => Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountEmail: Text(formatPhone(userState.phone)),
                    accountName: Text(
                      userState.name,
                      style: const TextStyle(fontSize: 24.0),
                    ),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(28, 29, 51, 1),
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
                                name: userState.name, id: userState.id)),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    trailing: const Icon(Icons.navigate_next),
                    title: const Text('Mi ubicación'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LocationScreen()),
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
                        MaterialPageRoute(
                            builder: (context) => const Deliveries()),
                      );
                    },
                  ),
                  const Divider(),
                  Visibility(
                    visible: userState.role == 'user',
                    child: ListTile(
                      leading: const Icon(Icons.motorcycle),
                      trailing: const Icon(Icons.navigate_next),
                      title: const Text('Quiero ser repartidor'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Register()),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: userState.role == 'courier',
                    child: ListTile(
                      leading: const Icon(Icons.maps_home_work),
                      trailing: const Icon(Icons.navigate_next),
                      title: const Text('Mapa'),
                      onTap: () {
                        if (userState.isDisabled) {
                          Navigator.pop(context);
                          showSnackBar(context,
                              "No puedes acceder al mapa porque tu cuenta ha sido deshabilitada.");
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CourierMap(key: ValueKey(DateTime.now()))),
                          );
                        }
                      },
                    ),
                  ),
                  Visibility(
                    visible: userState.role == 'courier',
                    child: ListTile(
                      leading: const Icon(Icons.motorcycle),
                      trailing: const Icon(Icons.navigate_next),
                      title: const Text('Mi vehiculo'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Vehicle(
                                  vehicle: userState.vehicle,
                                  id: userState.id)),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: userState.role == 'courier',
                    child: ListTile(
                      leading: const Icon(Icons.list),
                      trailing: const Icon(Icons.navigate_next),
                      title: const Text('Mis viajes'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Trips()),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: userState.role == 'admin',
                    child: ListTile(
                      leading: const Icon(Icons.motorcycle),
                      trailing: const Icon(Icons.navigate_next),
                      title: const Text('Repartidores'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Couriers()),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: userState.role == 'admin',
                    child: ListTile(
                      leading: const Icon(Icons.people),
                      trailing: const Icon(Icons.navigate_next),
                      title: const Text('Usuarios'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Users()),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: userState.role == 'admin',
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file_sharp),
                      trailing: const Icon(Icons.navigate_next),
                      title: const Text('Solicitudes'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Requests()),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: userState.role == 'admin',
                    child: ListTile(
                      leading: const Icon(Icons.settings),
                      trailing: const Icon(Icons.navigate_next),
                      title: const Text('Configuración'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ));
  }
}
