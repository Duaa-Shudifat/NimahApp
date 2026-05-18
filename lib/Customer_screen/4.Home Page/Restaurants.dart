import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Language/app_strings.dart';
import '../5.Profile/favorite_data.dart';
import 'BottomNavBar.dart';
import 'HomePage.dart';
import 'MyOrdersBar.dart';
import 'FavoriteBar.dart';
import 'RestaurantMenue.dart';
import 'SettingsBar.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({
    super.key,
    required this.title,
    required this.city, // ✅ الجديد
  });

  final String title;
  final String city; // ✅ الجديد

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  String get _cityName => widget.city.split(',').first.trim();

  Set<String> get favorites =>
      FavoriteData.favoriteRestaurants.map((e) => e["name"] as String).toSet();

  void toggleFavorite(String name, String image) {
    setState(() {
      if (favorites.contains(name)) {
        FavoriteData.favoriteRestaurants
            .removeWhere((item) => item["name"] == name);
      } else {
        FavoriteData.favoriteRestaurants.add({
          "name": name,
          "image": image,
        });
      }
    });
  }

  Widget _navIcon(String icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: SvgPicture.asset(
        icon,
        width: 28,
        height: 28,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Column(
        children: [
          const SizedBox(height: 50),

          // ElevatedButton(
          //   onPressed: addFakeProviders,
          //   style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
          //   child: const Text("Add Fake Data", style: TextStyle(color: Colors.white)),
          // ),
          // ElevatedButton(
          //   onPressed: deleteFakeProviders,
          //   style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          //   child: const Text("Delete Fake Data", style: TextStyle(color: Colors.white)),
          // ),

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: const Text(
                    "Restaurants",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),



          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 5),

                  // Search Bar
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: _searchQuery.isNotEmpty
                            ? Colors.deepOrange
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Icon(
                          Icons.search_rounded,
                          color: _searchQuery.isNotEmpty
                              ? Colors.deepOrange
                              : Colors.grey.shade500,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.trim().toLowerCase();
                              });
                            },
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: "Search restaurants...",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_searchQuery.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.food_bank_outlined,
                            color: Colors.red,
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Choose your favorite restaurant",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                  if (_searchQuery.isEmpty) const SizedBox(height: 12),

                  // ✅ StreamBuilder مع فلتر المدينة
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('FOOD_PROVIDERS')
                          .where('providerType', isEqualTo: _getProviderType(widget.title))
                          .where('city', isEqualTo: _cityName)
                          .where('VerificationStatus', isEqualTo: 'accepted')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.deepOrange,
                              ));
                        }

                        // فلتر: بس المطاعم اللي عندها صورة
                        final allProviders =
                        snapshot.data!.docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final image = data['logoUrl'] ?? '';
                          return image.isNotEmpty;
                        }).toList();

                        // فلتر البحث
                        final providers = _searchQuery.isEmpty
                            ? allProviders
                            : allProviders.where((doc) {
                          final data =
                          doc.data() as Map<String, dynamic>;
                          final name =
                          (data['name'] ?? '').toString().toLowerCase();
                          return name.contains(_searchQuery);
                        }).toList();

                        // ✅ رسالة لو ما في مطاعم بهاي المدينة
                        if (allProviders.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_off_rounded,
                                  size: 70,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No restaurants in $_cityName yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try selecting a different city',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // شاشة "لا توجد نتائج بحث"
                        if (providers.isEmpty && _searchQuery.isNotEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 70,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No results for "$_searchQuery"',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try a different name',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: providers.length,
                          itemBuilder: (context, index) {
                            final data = providers[index].data()
                            as Map<String, dynamic>;
                            final uid = providers[index].id;
                            final name = data["name"] ?? "Restaurant";
                            final image = data["logoUrl"] ?? "";

                            return _restaurantCard(
                                context, name, uid, image);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }


  Future<void> addFakeProviders() async {
    final providers = [
      // 🍽️ Meals
      {"name": "Zarqa Grand ",  "city": "Zarqa", "providerType": "meals",         "VerificationStatus": "accepted", "logoUrl": "ress1.jpg", "blocked": false},
      {"name": "See Food","city": "Zarqa", "providerType": "meals",         "VerificationStatus": "accepted", "logoUrl": "ress2.jpg", "blocked": false},
      {"name": "Shawarma House",          "city": "Zarqa", "providerType": "meals",         "VerificationStatus": "accepted", "logoUrl": "ress3.jpg", "blocked": false},
      {"name": "Steak",           "city": "Zarqa", "providerType": "meals",         "VerificationStatus": "accepted", "logoUrl": "ress4.jpg", "blocked": false},
      {"name": "Sham",         "city": "Zarqa", "providerType": "meals",         "VerificationStatus": "accepted", "logoUrl": "ress5.jpg", "blocked": false},
      {"name": "Burger",           "city": "Zarqa", "providerType": "meals",         "VerificationStatus": "accepted", "logoUrl": "ress6.jpg", "blocked": false},

      // 🥖 Bakery
      {"name": "Golden Bakery",   "city": "Zarqa", "providerType": "bakery",        "VerificationStatus": "accepted", "logoUrl": "bec1.jpg", "blocked": false},
      {"name": "Modern Bakery",   "city": "Zarqa", "providerType": "bakery",        "VerificationStatus": "accepted", "logoUrl": "bec2.jpg", "blocked": false},
      {"name": "Sanabel Bakery",       "city": "Zarqa", "providerType": "bakery",        "VerificationStatus": "accepted", "logoUrl": "bec3.jpg", "blocked": false},
      {"name": "Ali Sweets",           "city": "Zarqa", "providerType": "bakery",        "VerificationStatus": "accepted", "logoUrl": "bec4.jpg", "blocked": false},
      {"name": "Old Town Oven",           "city": "Zarqa", "providerType": "bakery",        "VerificationStatus": "accepted", "logoUrl": "bec5.jpg", "blocked": false},

      // 🛒 Store
      {"name": "Supermarket",       "city": "Zarqa", "providerType": "store",         "VerificationStatus": "accepted", "logoUrl": "store1.jpg", "blocked": false},
      {"name": "Al Noor",     "city": "Zarqa", "providerType": "store",         "VerificationStatus": "accepted", "logoUrl": "store2.jpg", "blocked": false},
      {"name": "Abu Khaled",  "city": "Zarqa", "providerType": "store",         "VerificationStatus": "accepted", "logoUrl": "store3.jpg", "blocked": false},
      {"name": "Al Ahli",     "city": "Zarqa", "providerType": "store",         "VerificationStatus": "accepted", "logoUrl": "store4.jpg", "blocked": false},

      // 🥦 Fresh Produce
      {"name": "Fresh Market",      "city": "Zarqa", "providerType": "fresh_produce", "VerificationStatus": "accepted", "logoUrl": "fresh1.jpg", "blocked": false},
      {"name": "Fresh Veggies", "city": "Zarqa", "providerType": "fresh_produce", "VerificationStatus": "accepted", "logoUrl": "fresh2.jpg", "blocked": false},
      {"name": "Central Market",  "city": "Zarqa", "providerType": "fresh_produce", "VerificationStatus": "accepted", "logoUrl": "fresh3.jpg", "blocked": false},
    ];

    for (final p in providers) {
      await FirebaseFirestore.instance.collection('FOOD_PROVIDERS').add(p);
    }

    print("✅ Added ${providers.length} providers!");
  }



  Future<void> deleteFakeProviders() async {
    final fakeName = [
      "Zarqa Grand ",
      "See Food",
      "Shawarma House",
      "Steak",
      "Sham",
      "Burger",


      "Golden Bakery",
      "Modern Bakery",
      "Sanabel Bakery",
      "Ali Sweets",
      "Old Town Oven",

      "Supermarket",
      "Al Noor",
      "Abu Khaled",
      "Al Ahli",
      "Fresh Market",
      "Fresh Veggies",
      "Central Market",


      "Zarqa Grand Restaurant",
      "Zarqa Grand",
      "Central Produce Market",


      "Jordan Authentic Kitchen",
      "Jordan Authentic",

      "Shawarma House",
      "Golden Mansaf",
      "Al Sham Falafel",
      "Nablus Knafeh",
      "Al Amal Golden Bakery",
      "Al Noor Modern Bakery",
      "Al Sanabel Bakery",
      "Om Ali Sweets",
      "Old Town Oven",
      "Zarqa Supermarket",
      "Al Noor Supermarket",
      "Abu Khaled Mini Market",
      "Al Ahli Supermarket",
      "Zarqa Fresh Market",
      "Abu Ahmad Fresh Veggies",
    ];

    for (final name in fakeName) {
      final query = await FirebaseFirestore.instance
          .collection('FOOD_PROVIDERS')
          .where('name', isEqualTo: name)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
      }
    }

    print("✅ Deleted all fake providers!");
  }
  Widget _restaurantCard(
      BuildContext context,
      String name,
      String providerUid,
      String image,
      ) {
    final isFav = favorites.contains(name);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // ✅ بعد
            builder: (_) => RestaurantMenuScreen(
              restaurantName: name,
              providerUid: providerUid,
              restaurantImage: image, // ✅ أضف هاي
            ),
        ));
      },
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
                child: image.isNotEmpty && image.startsWith("http")
                    ? Image.network(
                  image,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.orange.shade100,
                    child: const Icon(Icons.store, size: 60, color: Colors.deepOrange),
                  ),
                )
                    : image.isNotEmpty
                    ? Image.asset(
                  'assets/images/$image',
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

            _highlightText(name, _searchQuery),

            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => toggleFavorite(name, image),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProviderType(String title) {
    if (title == AppStrings.meals) return 'meals';
    if (title == AppStrings.freshProduce) return 'fresh_produce';
    if (title == AppStrings.bakeryProducts) return 'bakery';
    if (title == AppStrings.Store) return 'store';
    return '';
  }

  Widget _highlightText(String name, String query) {
    if (query.isEmpty) {
      return Text(
        name,
        style: const TextStyle(
          color: Colors.brown,
          fontSize: 30,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.white, blurRadius: 10)],
        ),
      );
    }

    final lowerName = name.toLowerCase();
    final matchIndex = lowerName.indexOf(query);

    if (matchIndex == -1) {
      return Text(
        name,
        style: const TextStyle(
          color: Colors.brown,
          fontSize: 30,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.white, blurRadius: 10)],
        ),
      );
    }

    final before = name.substring(0, matchIndex);
    final match = name.substring(matchIndex, matchIndex + query.length);
    final after = name.substring(matchIndex + query.length);

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.white, blurRadius: 10)],
        ),
        children: [
          TextSpan(text: before, style: const TextStyle(color: Colors.brown)),
          TextSpan(
            text: match,
            style: const TextStyle(
              color: Colors.deepOrange,
              decoration: TextDecoration.underline,
              decorationColor: Colors.deepOrange,
            ),
          ),
          TextSpan(text: after, style: const TextStyle(color: Colors.brown)),
        ],
      ),
    );
  }
}