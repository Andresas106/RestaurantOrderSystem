
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/Users.dart';
import '../../provider/user_provider_intern.dart';

class UserManagement extends StatefulWidget {
  @override
  _UserManagementState  createState() => _UserManagementState();

}

class _UserManagementState extends State<UserManagement> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: Consumer<UserProviderIntern>(
        builder: (context, userProvider, child) {
          return ListView.builder(
            itemCount: userProvider.users.length,
            itemBuilder: (context, index) {
              Users user = userProvider.users[index];
              return ListTile(
                title: Text('UID: ${user.uid}'),
                subtitle: Text('Role: ${user.role}'),
                trailing: FutureBuilder<String?>(
                  future: user.getEmail(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasData) {
                      return Text('Email: ${snapshot.data}');
                    } else {
                      return Text('No email');
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}