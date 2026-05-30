import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Cart/CartPanel.dart';
import '../Cart/cart_data.dart';
import 'BottomNavBar.dart';
import 'RestaurantMeals.dart';

class RestaurantMenuScreen extends StatelessWidget {
  const RestaurantMenuScreen({
    super.key,
    required this.restaurantName,
    required this.providerUid,
    required this.restaurantImage,
  });

  final String restaurantName;
  final String providerUid;
  final String restaurantImage;

  void openCart(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cart",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.80,
              height: MediaQuery.of(context).size.height,
              child: const CartPanel(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Text(
                restaurantName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.brown),
                  onPressed: () => openCart(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('FOOD_PROVIDERS')
                    .doc(providerUid)
                    .collection('MENU')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepOrange,
                      ),
                    );
                  }

                  final meals = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final available = (data['available'] ?? 0) as int;
                    return available > 0;
                  }).toList();
                  if (meals.isEmpty) {
                    return const Center(
                      child: Text(
                        "No meals available yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: const Row(
                          children: [
                            Icon(Icons.fastfood,
                                color: Colors.deepOrange, size: 30),
                            SizedBox(width: 10),
                            Text(
                              "Choose your favorite meal",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...meals.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        return GestureDetector(
                          onTap: () {
                            final Map<String, String> mealData = {
                              "name": data["name"] ?? "",
                              "price": "${data["price"] ?? "0"}",
                              "image": data["imageUrl"] ?? "",
                              "qty": "${data["available"] ?? 0}",
                              "desc": data["description"] ?? "",
                              "restaurantName": restaurantName,
                              "restaurantImage": restaurantImage,
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MealDetailsScreen(meal: mealData),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5CB58).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    data["imageUrl"] ?? "",
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.fastfood,
                                      size: 80,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data["name"] ?? "",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${data["price"] ?? "0"} JD",
                                        style: const TextStyle(
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                      if ((data["description"] ?? "")
                                          .isNotEmpty)
                                        Text(
                                          data["description"],
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}