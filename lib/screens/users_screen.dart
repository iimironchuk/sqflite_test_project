import 'package:flutter/material.dart';
import 'package:shopping_cart/widgets/add_user_dialog.dart';
import 'package:shopping_cart/widgets/user_list.dart';

class UserScreen extends StatefulWidget {
  static const routeName = '/user-screen';

  UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  void _refreshUsers(){
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users List'),
      ),
      floatingActionButton: AddUserDialog(onUserAdded: _refreshUsers,),
      body: UserList(),
    );
  }
}

 
