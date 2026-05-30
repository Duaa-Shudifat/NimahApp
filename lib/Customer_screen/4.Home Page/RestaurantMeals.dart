import 'package:flutter/material.dart';
import '../Cart/CartPanel.dart';
import '../Cart/cart_data.dart';
import 'BottomNavBar.dart';

class MealDetailsScreen extends StatefulWidget {
  final Map<String, String> meal;

  const MealDetailsScreen({super.key, required this.meal});

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  int quantity = 1;

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

  void _showClearCartDialog(BuildContext context, VoidCallback onClear) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.deepOrange),
            SizedBox(width: 10),
            Text("Different Restaurant",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            children: [
              const TextSpan(text: "Your cart has items from "),
              TextSpan(
                text: CartData.currentRestaurant,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.deepOrange),
              ),
              const TextSpan(
                  text: ".\n\nClear your cart and add from this restaurant?"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Keep Cart",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onClear();
            },
            child: const Text("Clear & Add",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context) {
    double mealPrice =
        double.tryParse(widget.meal["price"]!.replaceAll("\$", "").trim()) ?? 0.0;
    int maxAvailable = int.tryParse(widget.meal["qty"] ?? "0") ?? 0;
    String thisRestaurant = widget.meal["restaurantName"] ?? "";

    if (CartData.cartItems.isNotEmpty &&
        CartData.currentRestaurant.isNotEmpty &&
        CartData.currentRestaurant != thisRestaurant) {
      _showClearCartDialog(context, () {
        CartData.cartItems.clear();
        CartData.currentRestaurant = thisRestaurant;
        CartData.currentRestaurantImage = widget.meal["restaurantImage"] ?? "";
        _doAddToCart(mealPrice, maxAvailable, thisRestaurant);
      });
      return;
    }

    _doAddToCart(mealPrice, maxAvailable, thisRestaurant);
  }

  void _doAddToCart(double mealPrice, int maxAvailable, String thisRestaurant) {
    int existingIndex = CartData.cartItems.indexWhere(
          (item) => item.title == widget.meal["name"],
    );

    int currentInCart =
    (existingIndex != -1) ? CartData.cartItems[existingIndex].qty : 0;

    if (currentInCart + quantity <= maxAvailable) {
      setState(() {
        if (existingIndex != -1) {
          CartData.cartItems[existingIndex].qty += quantity;
        } else {
          CartData.cartItems.add(
            CartItemModel(
              title: widget.meal["name"]!,
              price: mealPrice,
              img: widget.meal["image"]!,
              qty: quantity,
              maxQty: maxAvailable,
            ),
          );
        }
        quantity = 1;
        CartData.currentRestaurant = thisRestaurant;
        CartData.currentRestaurantImage = widget.meal["restaurantImage"] ?? "";
      });
      _showMsg(context, "Added to cart ✅", Colors.deepOrange);
    } else {
      _showMsg(
        context,
        "Limit reached! You have $currentInCart in cart, only ${maxAvailable - currentInCart} left.",
        Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int maxAvailable = int.tryParse(widget.meal["qty"] ?? "0") ?? 0;
    final availableQty = widget.meal["qty"] ?? "0";
    final description = widget.meal["desc"] ?? "";
    final imageUrl = widget.meal["image"] ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Column(
        children: [
          SafeArea(
            child: SizedBox(
              height: 50,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Meal Details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.brown),
                      onPressed: () => openCart(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: imageUrl.startsWith("http")
                          ? Image.network(
                        imageUrl,
                        width: 240,
                        height: 240,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.fastfood,
                          size: 100,
                          color: Colors.deepOrange,
                        ),
                      )
                          : Image.asset(
                        imageUrl,
                        width: 240,
                        height: 240,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Text(
                                widget.meal["name"]!,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${widget.meal["price"]!} JD",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Available: $availableQty",
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Divider(thickness: 1, color: Colors.grey),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        description.isNotEmpty
                            ? description
                            : "Fresh and delicious meal made with high quality ingredients.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (quantity > 1) setState(() => quantity--);
                            },
                            child: const Icon(Icons.remove),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "$quantity",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              if (quantity < maxAvailable) {
                                setState(() => quantity++);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Reached maximum available stock")),
                                );
                              }
                            },
                            child: Icon(
                              Icons.add,
                              color: quantity < maxAvailable
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (maxAvailable == 0)
                      Container(
                        width: double.infinity,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            "Out of Stock",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () => _addToCart(context),
                            child: Text(
                              "Add to Cart ($quantity)",
                              style: const TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
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
    );
  }

  void _showMsg(BuildContext context, String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(text),
          backgroundColor: color,
          duration: const Duration(seconds: 1)),
    );
  }
}