import 'package:flutter/material.dart';

import 'AdminDashboard.dart';
import 'Driver.dart';
import 'ProvidersPage.dart';
import 'UsersPage.dart';
// import 'OrdersAdminPage.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {

  int currentIndex = 0;

  final List<Widget> pages = [
    const AdminDashboard(),
    const UsersPage(),
    const ProvidersPage(),
    const DriverPage(),
    // const (OrdersAdminPage),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.brown,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Users",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: "Providers",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: "Driver",
          ),

          // BottomNavigationBarItem(
          //   icon: Icon(Icons.receipt_long),
          //   label: "Orders",
          // ),
        ],
      ),
    );
  }
}