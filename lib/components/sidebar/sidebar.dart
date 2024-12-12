import 'package:app/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  void logout(BuildContext context) async {
    final authProvider = Provider.of<UserProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await authProvider.signout();

                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Signout failed: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userDetail = userProvider.userData;
    final Color bgColor = Colors.white;
    return Drawer(
      width: 350,
      backgroundColor: bgColor,
      child: ListView(
        children: [
          SizedBox(height: 20),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            leading: CircleAvatar(
              radius: 40,
              backgroundImage: userDetail?['profileImage'] == null
                  ? null
                  : NetworkImage(userDetail?['profileImage']),
              child: userDetail?['profileImage'] == null ||
                      userDetail?['profileImage'] == ''
                  ? const Icon(
                      Icons.perm_identity,
                      color: Colors.black,
                    )
                  : null,
            ),
            title: Text(
              "${userDetail?['name']}",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              "${userDetail?['email']}",
              style: TextStyle(color: Colors.black, fontSize: 11.5),
            ),
            trailing: SizedBox(),
            isThreeLine: true,
          ),
          SizedBox(height: 20),
          Divider(color: Colors.black, indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(Icons.home, color: Colors.black, size: 28),
            title: Text('Dashboard',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.normal)),
            onTap: () {
              Navigator.pushNamed(context, '/homescreen');
            },
          ),
          Divider(color: Colors.black, indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(Icons.add, color: Colors.black, size: 28),
            title: Text('Add Children',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.normal)),
            onTap: () {
              Navigator.pushNamed(context, '/addchildren');
            },
          ),
          Divider(color: Colors.black, indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.black, size: 28),
            title: Text('Settings',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.normal)),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          Divider(color: Colors.black, indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(Icons.info, color: Colors.black, size: 28),
            title: Text('About App',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.normal)),
            onTap: () {
              Navigator.pushNamed(context, '/description');
            },
          ),
          Divider(color: Colors.black, indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.black, size: 28),
            title: Text('Logout',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.normal)),
            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }
}
