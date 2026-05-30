import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../5.Profile/R - Password Setting.dart';
import '../5.Profile/S-Delete Setting.dart';
import 'BottomNavBar.dart';
import 'HomePage.dart';

import 'MyOrdersBar.dart';


import '../../language/app_strings.dart';
import 'FavoriteBar.dart';
import 'back_icon.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // void _showLanguageSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: const EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //
  //             const Text(
  //               "Select Language",
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //
  //             const SizedBox(height: 15),
  //
  //             ListTile(
  //               title: const Text("English"),
  //               onTap: () {
  //                 AppStrings.isArabic = false;
  //                 Navigator.pop(context);
  //               },
  //             ),
  //
  //             ListTile(
  //               title: const Text("العربية"),
  //               onTap: () {
  //                 AppStrings.isArabic = true;
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),

      body: Stack(
        children: [

          BackButtonPositioned(
            targetPage: const HomePage(),
          ),


          Column(
            children: [

              const SizedBox(height: 60),

              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),

                  child: Column(
                    children: [



                      ListTile(
                        leading: const Icon(
                          Icons.lock,
                          color: Colors.deepOrange,
                        ),
                        title: const Text("Password Setting"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const PasswordSettingsScreen(),
                            ),
                          );
                        },
                      ),



                      // // 🔥 LANGUAGE OPTION
                      // ListTile(
                      //   leading: const Icon(
                      //     Icons.language,
                      //     color: Colors.deepOrange,
                      //   ),
                      //   title: const Text("Language"),
                      //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      //   onTap: () {
                      //     _showLanguageSheet(context);
                      //   },
                      // ),

                      ListTile(
                        leading: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        title: const Text("Delete Account"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const DeleteAccountScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      bottomNavigationBar:  BottomNavBar(),

    );
  }
}