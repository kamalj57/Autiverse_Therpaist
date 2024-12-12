import 'package:app/components/sidebar/sidebar.dart';
import 'package:app/pages/home_page.dart';
import 'package:app/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userDetail = userProvider.userData;
    print('userData=> $userDetail');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leadingWidth: 120,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Builder(builder: (context) {
              return GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    CircleAvatar(
                      radius: 20,
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
                  ],
                ),
              );
            }),
            SizedBox(
              width: 10,
            ),
            Text(
              userDetail?['name'] != null
                  ? 'Welcome, Dr. ${userDetail?['name']}'
                  : 'Welcome, Unknown!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // leadingWidth: 80,
        titleSpacing: 0,
      ),
      drawer: Sidebar(),
      backgroundColor: Colors.white,
      body: const HomePage(),
    );
  }
}
