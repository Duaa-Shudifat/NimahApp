import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../4.Home Page/MyOrdersBar.dart';
import '../5.Profile/J - Delivery Adress.dart';
import '../5.Profile/L - Payment Methods.dart';
import '../Notification/notification_service.dart';
import 'CartPanel.dart';
import 'cart_data.dart';
import 'orders_data.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedAddress = "Tap to select address";
  String selectedPayment = "Tap to select payment";
  final TextEditingController noteController = TextEditingController();

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "Checkout",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ADDRESS
                        _sectionTitle("📍 Delivery Address"),
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DeliveryAddressScreen(),
                              ),
                            );
                            if (result != null) {
                              setState(() => selectedAddress = result);
                            }
                          },
                          child: _selectionCard(
                            icon: Icons.location_on,
                            text: selectedAddress,
                          ),
                        ),

                        const SizedBox(height: 20),
                        _sectionTitle("💳 Payment Method"),

                        GestureDetector(
                          onTap: () {
                            setState(() => selectedPayment = "Cash");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: selectedPayment == "Cash"
                                  ? Colors.deepOrange.withOpacity(0.08)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: selectedPayment == "Cash"
                                    ? Colors.deepOrange
                                    : Colors.grey.shade200,
                                width: selectedPayment == "Cash" ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.money,
                                    color: selectedPayment == "Cash"
                                        ? Colors.deepOrange
                                        : Colors.grey),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    "Cash",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Icon(
                                  selectedPayment == "Cash"
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: selectedPayment == "Cash"
                                      ? Colors.deepOrange
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PaymentMethodsScreen(),
                              ),
                            );
                            if (result != null) {
                              setState(() => selectedPayment = result);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selectedPayment != "Cash" &&
                                  selectedPayment != "Tap to select payment"
                                  ? Colors.deepOrange.withOpacity(0.08)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: selectedPayment != "Cash" &&
                                    selectedPayment != "Tap to select payment"
                                    ? Colors.deepOrange
                                    : Colors.grey.shade200,
                                width: selectedPayment != "Cash" &&
                                    selectedPayment != "Tap to select payment"
                                    ? 2
                                    : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  color: selectedPayment != "Cash" &&
                                      selectedPayment != "Tap to select payment"
                                      ? Colors.deepOrange
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    selectedPayment != "Cash" &&
                                        selectedPayment != "Tap to select payment"
                                        ? selectedPayment
                                        : "Credit / Debit Card",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Icon(
                                  selectedPayment != "Cash" &&
                                      selectedPayment != "Tap to select payment"
                                      ? Icons.check_circle
                                      : Icons.arrow_forward_ios,
                                  size: 16,
                                  color: selectedPayment != "Cash" &&
                                      selectedPayment != "Tap to select payment"
                                      ? Colors.deepOrange
                                      : Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // NOTE
                        _sectionTitle("📝 Note (Optional)"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            controller: noteController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Write your note...",
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // PLACE ORDER BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: _placeOrder,
                            child: const Text(
                              "Place Order",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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

          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.brown),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // ===== PLACE ORDER =====
  void _placeOrder() async {
    if (selectedAddress == "Tap to select address") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a delivery address ⚠️"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (selectedPayment == "Tap to select payment") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a payment method ⚠️"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final items = CartData.cartItems;
    final total = items.fold(0.0, (sum, i) => sum + i.qty * i.price);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final List<Map<String, dynamic>> itemsList = items.map((item) => {
      "Product_ID": item.title,
      "Quantity": item.qty,
    }).toList();

    try {
      // ✅ جيب city الزبون
      final customerDoc = await FirebaseFirestore.instance
          .collection('CUSTOMERS')
          .doc(uid)
          .get();
      final rawCity = customerDoc['selectedCity'] ?? customerDoc['city'] ?? '';
// بعد (نفس التنظيف مثل الدرايفر)
      final customerCity = rawCity.toString()
          .replaceAll(', Jordan', '')
          .replaceAll(',Jordan', '')
          .trim();
      print("ORDER CITY: '$customerCity'"); // ← هون بس

      String providerName = CartData.currentRestaurant;
      String realProviderId = providerName;

      var providerSnapshot = await FirebaseFirestore.instance
          .collection('FOOD_PROVIDERS')
          .where('name', isEqualTo: providerName)
          .limit(1)
          .get();

      if (providerSnapshot.docs.isNotEmpty) {
        realProviderId = providerSnapshot.docs.first.id;
      }

      final orderData = {
        "Customer_ID": uid,
        "Driver_ID": "",
        "City": customerCity, // ✅
        "Items": itemsList,
        "Notes": noteController.text.trim(),
        "Order_Date": FieldValue.serverTimestamp(),
        "Provider_ID": realProviderId,
        "Provider_Name": providerName,
        "Provider_Image": CartData.currentRestaurantImage,
        "Status": "Pending",  // ← هيك صح        "Total_Price": total,
        "Payment_Method": selectedPayment,
        "Address": selectedAddress,
      };

      final orderRef = await FirebaseFirestore.instance.collection('ORDERS').add(orderData);
      final String orderId = orderRef.id;



// جيب fcmToken المطعم وابعتله إشعار
      final providerDoc = await FirebaseFirestore.instance
          .collection('FOOD_PROVIDERS')
          .doc(realProviderId)
          .get();

      final String? providerToken = providerDoc['fcmToken'];

      if (providerToken != null) {
        await NotificationService.sendNotification(
          fcmToken: providerToken,
          title: "New Order Received! 🍽️",
          body: "You have a new order waiting for your approval.",
          orderId: orderId,
          type: "order",
        );
        await FirebaseFirestore.instance
            .collection('USER_NOTIFICATIONS')
            .add({
          'userId': realProviderId,
          'title': "New Order Received! 🍽️",
          'body': "You have a new order waiting for your approval.",
          'type': "order",
          'orderId': orderId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      for (var item in items) {
        var mealQuery = await FirebaseFirestore.instance
            .collection('FOOD_PROVIDERS')
            .doc(realProviderId)
            .collection('MENU')
            .where('name', isEqualTo: item.title)
            .limit(1)
            .get();

        if (mealQuery.docs.isNotEmpty) {
          String mealDocId = mealQuery.docs.first.id;
          await FirebaseFirestore.instance
              .collection('FOOD_PROVIDERS')
              .doc(realProviderId)
              .collection('MENU')
              .doc(mealDocId)
              .update({
            'available': FieldValue.increment(-item.qty),
          });
        }
      }

      CartData.cartItems.clear();
      CartData.currentRestaurant = "";

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ActiveOrdersEmptyScreen()),
            (route) => false,
      );

    } catch (e) {
      print("Error placing order: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred while placing the order. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ===== SELECTION CARD =====
  Widget _selectionCard({required IconData icon, required String text}) {
    final bool isDefault = text == "Tap to select address" ||
        text == "Tap to select payment";
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDefault ? Colors.orange.shade200 : Colors.deepOrange,
          width: isDefault ? 1 : 2,
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              color: isDefault ? Colors.grey : Colors.deepOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDefault ? Colors.grey : Colors.black,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  // ===== HELPERS =====
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.brown)),
    );
  }
}