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
  String _currentFilter = 'all';
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
      _applyFilter();
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _applyFilter() {
    List<UserModel> filteredUsers;
    switch (_currentFilter) {
      case 'enabled':
        filteredUsers = users.where((user) => !user.isDisabled).toList();
        break;
      case 'disabled':
        filteredUsers = users.where((user) => user.isDisabled).toList();
        break;
      case 'all':
      default:
        filteredUsers = List.from(users);
    }
    setState(() {
      users = filteredUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            icon: const Icon(Icons.filter_alt),
            onSelected: (String value) {
              setState(() {
                _currentFilter = value;
              });
              _applyFilter();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'all', child: Text('Todos')),
              const PopupMenuItem<String>(
                  value: 'enabled', child: Text('Habilitados')),
              const PopupMenuItem<String>(
                  value: 'disabled', child: Text('Deshabilitados')),
            ],
          ),
        ],
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
                          child: Image.asset('assets/images/empty.png')),
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
                        leading: Icon(
                          Icons.person,
                          color: user.isDisabled ? Colors.red : Colors.blueGrey,
                        ),
                        trailing: const Icon(Icons.navigate_next),
                        title: Text(user.name),
                        subtitle: Text(user.phone),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserDeliveries(
                                        isDisabled: user.isDisabled,
                                        originLocation: user.originLocation,
                                        name: user.name,
                                        userId: user.id,
                                      ))).then((value) => _handleGetAllUsers());
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
