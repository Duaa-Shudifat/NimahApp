import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Language/app_strings.dart';
import '../5.Profile/favorite_data.dart';
import 'BottomNavBar.dart';
import 'HomePage.dart';
import 'SettingsBar.dart';
import 'MyOrdersBar.dart';
import 'back_icon.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {

  void removeFavorite(int index) {
    setState(() {
      FavoriteData.favoriteRestaurants.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {

    final restaurants = FavoriteData.favoriteRestaurants;

    return Scaffold(


      backgroundColor: const Color(0xFFF5CB58),

      body: Stack(
        children: [

          BackButtonPositioned(
            targetPage: const HomePage(),
          ),
          Column(
            children: [

              const SizedBox(height: 70),

               Text(
                AppStrings.favoritesTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),

                  child: restaurants.isEmpty
                      ? const Center(child: Text("No favorites yet"))
                      : ListView.builder(
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final item = restaurants[index];

                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    Colors.white.withOpacity(0.5),
                                    BlendMode.lighten,
                                  ),
                                  child: item["image"] != null && item["image"]!.startsWith("http")
                                      ? Image.network(
                                    item["image"]!,
                                    width: double.infinity,
                                    height: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.orange.shade100,
                                      child: const Icon(Icons.store, size: 60, color: Colors.deepOrange),
                                    ),
                                  )
                                      : Container(
                                    color: Colors.orange.shade100,
                                    width: double.infinity,
                                    height: 140,
                                    child: const Icon(Icons.store, size: 60, color: Colors.deepOrange),
                                  ),
                                ),
                              ),

                              Text(
                                item["name"]!,
                                style: const TextStyle(
                                  color: Colors.brown,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),

                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () => removeFavorite(index),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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