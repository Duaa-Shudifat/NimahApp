import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'FavoriteBar.dart';
import 'HomePage.dart';
import 'MyOrdersBar.dart';
import 'SettingsBar.dart';



class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  void _go(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xFFF5CB58),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            // HOME
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/home.svg',
                width: 28,
                height: 28,
              ),
              onPressed: () => _go(context, const HomePage()),
            ),

            // ORDERS
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/your_order.svg',
                width: 30,
                height: 30,
              ),
              onPressed: () => _go(context, const ActiveOrdersEmptyScreen()),
            ),

            // FAVORITE
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/favorite.svg',
                width: 26,
                height: 26,
              ),
              onPressed: () => _go(context, const Favorite()),
            ),

            // SETTINGS
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/setting_icon.svg',
                width: 28,
                height: 28,
              ),
              onPressed: () => _go(context, const SettingsScreen()),
            ),
          ],
        ),
      ),
    );
  }
}