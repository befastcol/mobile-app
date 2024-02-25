import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/screens/home/users/deliveries.dart';
import 'package:flutter/material.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  List<UserModel> users = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _handleGetAllUsers();
  }

  Future _handleGetAllUsers() async {
    try {
      setState(() => isLoading = true);
      users = await UsersAPI().getAllUsers();
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.amber,
        title: const Text("Usuarios"),
      ),
      body: RefreshIndicator(
        onRefresh: _handleGetAllUsers,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : users.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 180),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 50),
                          child: Image.asset('assets/empty.png')),
                      const Center(
                          child: Text(
                        'No hay usuarios',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      )),
                    ],
                  )
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: const Icon(Icons.person),
                        trailing: const Icon(Icons.navigate_next),
                        title: Text(user.name),
                        subtitle: Text(user.phone),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserDeliveries(
                                        originLocation: user.originLocation,
                                        name: user.name,
                                        userId: user.id,
                                      )));
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
