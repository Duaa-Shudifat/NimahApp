import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'CheckoutScreen.dart';
import 'cart_data.dart';

class CartPanel extends StatefulWidget {
  const CartPanel({super.key});

  @override
  State<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends State<CartPanel> {
  List<CartItemModel> get cartItems => CartData.cartItems;

  double getTotal() {
    double total = 0;
    for (var item in cartItems) {
      total += item.qty * item.price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF7E6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/cart.svg',
                width: 22,
                height: 22,
                color: Colors.deepOrange,
              ),
              const SizedBox(width: 10),
              const Text(
                "My Cart",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
              child: Text(
                "Your cart is empty 🛒",
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.separated(
              itemCount: cartItems.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // ✅ صورة من network أو asset
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: item.img.startsWith("http")
                            ? Image.network(
                          item.img,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(
                            Icons.fastfood,
                            size: 55,
                            color: Colors.deepOrange,
                          ),
                        )
                            : Image.asset(
                          item.img,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // ✅ سعر double
                            Text(
                              "${item.price.toStringAsFixed(2)} JD",
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                          Colors.deepOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (item.qty > 1) item.qty--;
                                });
                              },
                              child:
                              const Icon(Icons.remove, size: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${item.qty}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            // ✅ بعد
                            // ✅ بعد — نفس المنطق بس أوضح
                            // ✅ في CartPanel — عدّل زر الـ +
                            GestureDetector(
                              onTap: () {
                                if (item.qty < item.maxQty) {
                                  setState(() => item.qty++);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Max is ${item.maxQty} ⚠️"),
                                      backgroundColor: Colors.orange,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              child: Icon(
                                Icons.add,
                                size: 16,
                                color: item.qty < item.maxQty ? Colors.black : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            cartItems.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // ✅ total بـ double
                Text(
                  "${getTotal().toStringAsFixed(2)} JD",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CheckoutScreen(),
                  ),
                );
              },
              child: const Text(
                "Checkout",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}