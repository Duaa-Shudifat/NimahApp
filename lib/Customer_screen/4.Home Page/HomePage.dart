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
import 'RestaurantMeals.dart';
import 'RestaurantMenue.dart';
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
                      color: Colors.deepOrange.withOpacity(0.4),
                    ),
                  ),
                  child: TextField(
                    controller: _addrController,
                    readOnly: true,
                    style: const TextStyle(fontSize: 15),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.location_on_rounded,
                        color: Colors.deepOrange,
                      ),
                      hintText: 'Enter your address...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Quick select',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
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
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3DC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.deepOrange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_city_rounded,
                              size: 14,
                              color: Colors.deepOrange,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              city,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.brown,
                              ),
                            ),
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Confirm address',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _notificationBell() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return InkWell(
        onTap: _openNotificationsPanel,
        borderRadius: BorderRadius.circular(50),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 22,
                height: 22,
                child: SvgPicture.asset(
                  'assets/icons/notification.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('USER_NOTIFICATIONS')
          .where('userId', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        bool hasUnread = false;
        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['isRead'] != true) {
              hasUnread = true;
              break;
            }
          }
        }

        return InkWell(
          onTap: () async {
            await _markNotificationsAsRead();
            _openNotificationsPanel();
          },
          borderRadius: BorderRadius.circular(50),
          child: SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: SvgPicture.asset(
                        'assets/icons/notification.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _markNotificationsAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('USER_NOTIFICATIONS')
        .where('userId', isEqualTo: user.uid)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data['isRead'] != true) {
        batch.update(doc.reference, {'isRead': true});
      }
    }
    await batch.commit();
  }

  void _openNotificationsPanel() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Notifications",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) {
        final isArabic = AppStrings.isArabic;
        return Align(
          alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
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
            begin: isArabic ? const Offset(-1, 0) : const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
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
                            padding:
                            const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(23),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.deepOrange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      circleSvgIcon1(
                        context,
                        'assets/icons/cart.svg',
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
                                    width: MediaQuery.of(context).size.width *
                                        0.80,
                                    height:
                                    MediaQuery.of(context).size.height,
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
                        },
                      ),
                      _notificationBell(),
                      circleSvgIcon1(
                        context,
                        'assets/icons/profile.svg',
                            () {
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
                                    width: MediaQuery.of(context).size.width *
                                        0.80,
                                    height:
                                    MediaQuery.of(context).size.height,
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
                          ).then((_) => _loadUserCity());
                        },
                      ),
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
                      _buildBestSeller(),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              AppStrings.recommended,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildRecommended(),
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

  Widget _buildBestSeller() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchTopSellingMeals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _foodCard("assets/images/food_card1.png", "JD10.3"),
                _foodCard("assets/images/food_card2.png", "JD12.0"),
                _foodCard("assets/images/food_card3.png", "JD8.50"),
                _foodCard("assets/images/food_card4.png", "JD9.00"),
              ],
            ),
          );
        }

        final meals = snapshot.data!;
        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MealDetailsScreen(
                        meal: {
                          "name": meal["name"]?.toString() ?? "",
                          "price": meal["price"]?.toString() ?? "0",
                          "image": meal["imageUrl"]?.toString() ?? "",
                          "qty": meal["qty"]?.toString() ?? "0",
                          "desc": meal["desc"]?.toString() ?? "",
                          "restaurantName":
                          meal["restaurantName"]?.toString() ?? "",
                        },
                      ),
                    ),
                  );
                },
                child: _productCard(
                  meal["imageUrl"]?.toString() ?? "",
                  "JD${meal["price"]}",
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTopSellingMeals() async {
    final city = _deliveryAddress.split(',').first.trim();

    final providersSnap = await FirebaseFirestore.instance
        .collection('FOOD_PROVIDERS')
        .where('city', isEqualTo: city)
        .where('VerificationStatus', isEqualTo: 'accepted')
        .get();

    if (providersSnap.docs.isEmpty) return [];

    final providerIds = providersSnap.docs.map((d) => d.id).toSet();

    final ordersSnap =
    await FirebaseFirestore.instance.collection('ORDERS').get();

    final Map<String, int> salesCount = {};
    for (var order in ordersSnap.docs) {
      final data = order.data();
      final providerId = data['Provider_ID']?.toString() ?? '';
      if (!providerIds.contains(providerId)) continue;

      final items = (data['Items'] ?? []) as List;
      for (var item in items) {
        final name = item['Product_ID']?.toString() ?? '';
        final qty = (item['Quantity'] ?? 1) as int;
        if (name.isNotEmpty) {
          salesCount[name] = (salesCount[name] ?? 0) + qty;
        }
      }
    }

    if (salesCount.isEmpty) return [];

    final sorted = salesCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topNames = sorted.take(10).map((e) => e.key).toList();

    final List<Map<String, dynamic>> result = [];

    for (final name in topNames) {
      try {
        final productQuery = await FirebaseFirestore.instance
            .collection('PRODUCT')
            .where('Name', isEqualTo: name)
            .where('Provider_ID', whereIn: providerIds.toList())
            .limit(1)
            .get();

        if (productQuery.docs.isNotEmpty) {
          final data = Map<String, dynamic>.from(
              productQuery.docs.first.data() as Map);

          result.add({
            'name': data['Name'] ?? '',
            'price': data['Price'] ?? 0,
            'imageUrl': data['image'] ?? '',
            'qty': data['qty'] ?? 0,
            'desc': data['Description'] ?? '',
            'restaurantName': _getProviderName(
                providersSnap.docs, data['Provider_ID'] ?? ''),
            'restaurantUid': data['Provider_ID'] ?? '',
          });
        }
      } catch (e) {
        debugPrint("fetchTopMeals error for $name: $e");
      }
    }

    return result;
  }

  String _getProviderName(
      List<QueryDocumentSnapshot> providers, String providerId) {
    try {
      return providers
          .firstWhere((d) => d.id == providerId)
          .data()
          .toString()
          .contains('name')
          ? (providers.firstWhere((d) => d.id == providerId).data()
      as Map<String, dynamic>)['name'] ??
          ''
          : '';
    } catch (_) {
      return '';
    }
  }
// ════════════════════════════════════════
  // RECOMMENDED — مطاعم مرتبة حسب المبيعات
  // ════════════════════════════════════════
  Widget _buildRecommended() {
    final city = _deliveryAddress.split(',').first.trim();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchTopProviders(city),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 170,
            child: Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 170,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _recommendedCard('assets/images/food_rec1.png', 'Restaurant'),
                _recommendedCard('assets/images/food_rec2.png', 'Restaurant'),
                _recommendedCard('assets/images/food_rec3.png', 'Restaurant'),
              ],
            ),
          );
        }

        final providers = snapshot.data!;

        return SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final p = providers[index];
              final name = p['name']?.toString() ?? 'Restaurant';
              final image = p['logoUrl']?.toString() ?? '';
              final uid = p['uid']?.toString() ?? '';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantMenuScreen(
                        restaurantName: name,
                        providerUid: uid,
                        restaurantImage: image,
                      ),
                    ),
                  );
                },
                child: _recommendedCardNetwork(image, name),
              );
            },
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTopProviders(String city) async {
    // 1. جيب كل مطاعم المدينة المقبولة
    final providersSnap = await FirebaseFirestore.instance
        .collection('FOOD_PROVIDERS')
        .where('city', isEqualTo: city)
        .where('VerificationStatus', isEqualTo: 'accepted')
        .get();

    if (providersSnap.docs.isEmpty) return [];

    // فلتر: بس اللي عندهم صورة
    final providers = providersSnap.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return (data['logoUrl']?.toString() ?? '').isNotEmpty;
    }).toList();

    if (providers.isEmpty) return [];

    final providerIds = providers.map((d) => d.id).toSet();

    // 2. احسب مجموع المبيعات لكل مطعم من ORDERS
    final ordersSnap = await FirebaseFirestore.instance
        .collection('ORDERS')
        .get();

    final Map<String, int> salesPerProvider = {};

    for (var order in ordersSnap.docs) {
      final data = order.data();
      final providerId = data['Provider_ID']?.toString() ?? '';
      if (!providerIds.contains(providerId)) continue;

      final items = (data['Items'] ?? []) as List;
      int totalQty = 0;
      for (var item in items) {
        totalQty += (item['Quantity'] ?? 1) as int;
      }
      salesPerProvider[providerId] =
          (salesPerProvider[providerId] ?? 0) + totalQty;
    }

    // 3. رتّب المطاعم من الأكثر مبيعاً للأقل
    providers.sort((a, b) {
      final salesA = salesPerProvider[a.id] ?? 0;
      final salesB = salesPerProvider[b.id] ?? 0;
      return salesB.compareTo(salesA);
    });

    // 4. رجّع أعلى 10
    return providers.take(10).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'uid': doc.id,
        'name': data['name'] ?? '',
        'logoUrl': data['logoUrl'] ?? '',
        'sales': salesPerProvider[doc.id] ?? 0,
      };
    }).toList();
  }
  // ════════════════════════════════════════
  // WIDGETS
  // ════════════════════════════════════════

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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                price,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// كارد المطعم في Recommended — يعرض صورة المطعم + اسمه
  Widget _recommendedCardNetwork(String imageUrl, String restaurantName) {
    return Container(
      width: 160,
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // صورة المطعم
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.orange.shade100,
                child:
                const Icon(Icons.store, size: 60, color: Colors.deepOrange),
              ),
            ),
          ),
          // تدرج داكن في الأسفل
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // اسم المطعم
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Text(
              restaurantName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

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
            builder: (context) => CategoryScreen(title: title, city: city),
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
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
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
            child: Image.asset(
              imagePath,
              width: 80,
              height: 110,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 35,
            left: 17,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                price,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _recommendedCard(String imagePath, String label) {
    return Container(
      width: 160,
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imagePath,
              height: 170,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}