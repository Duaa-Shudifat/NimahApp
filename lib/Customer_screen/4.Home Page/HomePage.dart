import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../5.Profile/A - Profile.dart';
import '../Notification/notification.dart';
import 'MyOrdersBar.dart';
import 'FavoriteBar.dart';
import '../Cart/CartPanel.dart';
import '../../language/app_strings.dart';
import 'SettingsBar.dart';
import 'Restaurants.dart';
import 'BottomNavBar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _deliveryAddress = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserCity();
    _updateProductCategories(); // ✅

  }

  Future<void> _loadUserCity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('CUSTOMERS')
        .doc(user.uid)
        .get();

    if (doc.exists && mounted) {
      final data = doc.data()!;
      final city = data['selectedCity'] ?? data['city'];
      if (city != null) {
        setState(() {
          _deliveryAddress = city.toString().contains('Jordan')
              ? city
              : '$city, Jordan';
        });
      }
    }
  }

  void _showAddressPicker() {
    final TextEditingController _addrController =
    TextEditingController(text: _deliveryAddress);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delivery address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.deepOrange.withOpacity(0.4)),
                  ),
                  child: TextField(
                    controller: _addrController,
                    readOnly: true,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_on_rounded,
                          color: Colors.deepOrange),
                      hintText: 'Enter your address...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Quick select',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Amman, Jordan',
                    'Zarqa, Jordan',
                    'Irbid, Jordan',
                    'Balqa, Jordan',
                    'Madaba, Jordan',
                    'Aqaba, Jordan',
                    'Karak, Jordan',
                    'Tafilah, Jordan',
                    'Ma\'an, Jordan',
                    'Jerash, Jordan',
                    'Ajloun, Jordan',
                    'Mafraq, Jordan',
                  ].map((city) {
                    return GestureDetector(
                      onTap: () => _addrController.text = city,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3DC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.deepOrange.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_city_rounded,
                                size: 14, color: Colors.deepOrange),
                            const SizedBox(width: 5),
                            Text(city,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.brown)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final newAddr = _addrController.text.trim();
                      if (newAddr.isNotEmpty) {
                        setState(() => _deliveryAddress = newAddr);
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('CUSTOMERS')
                              .doc(user.uid)
                              .update({'selectedCity': newAddr});
                        }
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Confirm address',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
      AppStrings.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5CB58),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF5CB58),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _showAddressPicker,
                          child: Container(
                            height: 46,
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(23),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    color: Colors.deepOrange, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Delivering to',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        _deliveryAddress,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.deepOrange,
                                    size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      circleSvgIcon1(context, 'assets/icons/cart.svg',
                              () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: "Cart",
                              barrierColor: Colors.black54,
                              transitionDuration:
                              const Duration(milliseconds: 300),
                              pageBuilder: (context, _, __) {
                                final isArabic = AppStrings.isArabic;
                                return Align(
                                  alignment: isArabic
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
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
                                final isArabic = AppStrings.isArabic;
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: isArabic
                                        ? const Offset(-1, 0)
                                        : const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            );
                          }),
                      circleSvgIcon1(
                          context, 'assets/icons/notification.svg', () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: "Notifications",
                          barrierColor: Colors.black54,
                          transitionDuration:
                          const Duration(milliseconds: 300),
                          pageBuilder: (context, _, __) {
                            final isArabic = AppStrings.isArabic;
                            return Align(
                              alignment: isArabic
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.80,
                                  height: MediaQuery.of(context).size.height,
                                  child: const NotificationsPanel(),
                                ),
                              ),
                            );
                          },
                          transitionBuilder: (context, animation, _, child) {
                            final isArabic = AppStrings.isArabic;
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: isArabic
                                    ? const Offset(-1, 0)
                                    : const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                        );
                      }),
                      circleSvgIcon1(
                          context, 'assets/icons/profile.svg', () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: "Profile",
                          barrierColor: Colors.black54,
                          transitionDuration:
                          const Duration(milliseconds: 300),
                          pageBuilder: (context, _, __) {
                            final isArabic = AppStrings.isArabic;
                            return Align(
                              alignment: isArabic
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              child: Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.80,
                                  height: MediaQuery.of(context).size.height,
                                  child: const ProfileScreen(),
                                ),
                              ),
                            );
                          },
                          transitionBuilder: (context, animation, _, child) {
                            final isArabic = AppStrings.isArabic;
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: isArabic
                                    ? const Offset(-1, 0)
                                    : const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                        ).then((_) => _loadUserCity()); // ✅
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.goodMorning,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  Text(
                    AppStrings.breakfastTime,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _categorySvgItem(
                                context: context,
                                path: 'assets/icons/Meals.svg',
                                title: AppStrings.meals,
                                city: _deliveryAddress,
                              ),
                              _categorySvgItem(
                                context: context,
                                path: 'assets/icons/Greens.svg',
                                title: AppStrings.freshProduce,
                                city: _deliveryAddress,
                              ),
                              _categorySvgItem(
                                context: context,
                                path: 'assets/icons/Desserts.svg',
                                title: AppStrings.bakeryProducts,
                                city: _deliveryAddress,
                              ),
                              _categorySvgItem(
                                context: context,
                                path: 'assets/icons/Store.svg',
                                title: AppStrings.Store,
                                city: _deliveryAddress,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Divider(
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle(AppStrings.bestSeller),
                      const SizedBox(height: 10),
                      _buildBestSeller(), // ✅
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              AppStrings.recommended,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildRecommended(), // ✅
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }

  // ===== FIRESTORE WIDGETS =====
  Widget _buildBestSeller() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('MENU')
          .where('category', isEqualTo: 'best_seller')
          .snapshots(),
      builder: (context, snapshot) {

        //
        // if (!snapshot.hasData) {

        if (true) {
          return SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _foodCard("assets/images/food_card1.png", "\JD10.3"),
                _foodCard("assets/images/food_card2.png", "\JD12.0"),
                _foodCard("assets/images/food_card3.png", "\JD8.50"),
                _foodCard("assets/images/food_card4.png", "\JD9.00"),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _productCard(data['imageUrl'] ?? '', '\$${data['price']}');
            },
          ),
        );
      },
    );
  }

  Widget _buildRecommended() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collectionGroup('MENU')
          .where('category', isEqualTo: 'recommended')
          .snapshots(),
      builder: (context, snapshot) {

        //if (!snapshot.hasData) {
        if (true) {
          return SizedBox(
            height: 170,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _recommendedCard('assets/images/food_rec1.png', '\JD12'),
                _recommendedCard('assets/images/food_rec2.png', '\JD18'),
                _recommendedCard('assets/images/food_rec3.png', '\JD18'),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _recommendedCardNetwork(data['imageUrl'] ?? '', '\$${data['price']}');
            },
          ),
        );
      },
    );
  }

  Widget _productCard(String imageUrl, String price) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(price,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendedCardNetwork(String imageUrl, String price) {
    return Container(
      width: 160,
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration:
      BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_not_supported),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                price,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== STATIC WIDGETS =====

  static Widget circleSvgIcon1(
      BuildContext context,
      String path,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 22,
          height: 22,
          child: SvgPicture.asset(path, fit: BoxFit.contain),
        ),
      ),
    );
  }

  static Widget _categorySvgItem({
    required BuildContext context,
    required String path,
    required String title,
    required String city,
    double size = 80,
    Color bgColor = const Color(0xFFF3E9B5),
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryScreen(
              title: title,
              city: city,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  path,
                  width: size * 0.6,
                  height: size * 0.6,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(title),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _updateProductCategories() async {
    final ordersSnap = await FirebaseFirestore.instance
        .collection('ORDERS')
        .get();

    final Map<String, int> salesCount = {};
    for (var order in ordersSnap.docs) {
      final data = order.data();
      final List items = data['Items'] ?? [];
      for (var item in items) {
        final String productName = item['Product_ID'] ?? '';
        final int qty = item['Quantity'] ?? 1;
        if (productName.isNotEmpty) {
          salesCount[productName] = (salesCount[productName] ?? 0) + qty;
        }
      }
    }

    if (salesCount.isEmpty) return;

    final sorted = salesCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bestSellers = sorted.take(3).map((e) => e.key).toSet();
    final recommended = sorted.skip(3).take(3).map((e) => e.key).toSet();

    final menuSnap = await FirebaseFirestore.instance
        .collectionGroup('MENU')
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var product in menuSnap.docs) {
      final name = product.data()['name'] ?? '';
      String newCategory = '';
      if (bestSellers.contains(name)) {
        newCategory = 'best_seller';
      } else if (recommended.contains(name)) {
        newCategory = 'recommended';
      }
      batch.update(product.reference, {'category': newCategory});
    }
    await batch.commit();
  }



  static Widget _foodCard(String imagePath, String price) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(imagePath,
                width: 80, height: 110, fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 35,
            left: 17,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(price,
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }



  static Widget _recommendedCard(String imagePath, String price) {
    return Container(
      width: 160,
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration:
      BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(imagePath,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}