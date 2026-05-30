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
  bool _isLoading = false;

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
                          onTap: () => setState(() => selectedPayment = "Cash"),
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
                                  child: Text("Cash",
                                      style: TextStyle(fontWeight: FontWeight.bold)),
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
                                Icon(Icons.credit_card,
                                    color: selectedPayment != "Cash" &&
                                        selectedPayment != "Tap to select payment"
                                        ? Colors.deepOrange
                                        : Colors.grey),
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
                            onPressed: _isLoading ? null : _placeOrder,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
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
              onPressed: _isLoading ? null : () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  void _placeOrder() async {
    if (selectedAddress == "Tap to select address") {
      _showSnack("Please select a delivery address ⚠️", Colors.orange);
      return;
    }
    if (selectedPayment == "Tap to select payment") {
      _showSnack("Please select a payment method ⚠️", Colors.orange);
      return;
    }
    if (CartData.cartItems.isEmpty) {
      _showSnack("Your cart is empty ⚠️", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _showSnack("User not logged in ⚠️", Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      final items = CartData.cartItems;
      final total = items.fold(0.0, (sum, i) => sum + i.qty * i.price);

      final customerDoc = await FirebaseFirestore.instance
          .collection('CUSTOMERS')
          .doc(uid)
          .get();

      if (!customerDoc.exists) {
        _showSnack("Customer data not found ⚠️", Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      final customerData = customerDoc.data()!;
      final customerLat =
      (customerData['lat'] ?? customerData['latitude'] ?? 0.0).toDouble();
      final customerLng =
      (customerData['lng'] ?? customerData['longitude'] ?? 0.0).toDouble();
      final rawCity =
      (customerData['selectedCity'] ?? customerData['city'] ?? '')
          .toString()
          .replaceAll(', Jordan', '')
          .replaceAll(',Jordan', '')
          .trim();

      String providerName = CartData.currentRestaurant;
      String realProviderId = '';
      double restaurantLat = 0.0;
      double restaurantLng = 0.0;
      String providerImage = CartData.currentRestaurantImage;

      final providerSnapshot = await FirebaseFirestore.instance
          .collection('FOOD_PROVIDERS')
          .where('name', isEqualTo: providerName)
          .limit(1)
          .get();

      if (providerSnapshot.docs.isNotEmpty) {
        final providerDoc = providerSnapshot.docs.first;
        realProviderId = providerDoc.id;
        final providerData = providerDoc.data();
        restaurantLat =
            (providerData['lat'] ?? providerData['latitude'] ?? 0.0).toDouble();
        restaurantLng =
            (providerData['lng'] ?? providerData['longitude'] ?? 0.0).toDouble();
        if (providerImage.isEmpty) {
          providerImage = providerData['logoUrl'] ?? '';
        }
      } else {
        _showSnack("Restaurant not found. Please try again ⚠️", Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      final List<Map<String, dynamic>> itemsList = items
          .map((item) => {
        "Product_ID": item.title,
        "Quantity": item.qty,
      })
          .toList();

      final orderData = {
        "Customer_ID": uid,
        "Driver_ID": "",
        "City": rawCity,
        "Items": itemsList,
        "Notes": noteController.text.trim(),
        "Order_Date": FieldValue.serverTimestamp(),
        "Provider_ID": realProviderId,
        "Provider_Name": providerName,
        "Provider_Image": providerImage,
        "Status": "Pending",
        "Total_Price": total,
        "Payment_Method": selectedPayment,
        "Address": selectedAddress,
        "Customer_Lat": customerLat,
        "Customer_Lng": customerLng,
        "Restaurant_Lat": restaurantLat,
        "Restaurant_Lng": restaurantLng,
        "Driver_Lat": null,
        "Driver_Lng": null,
      };

      final orderRef = await FirebaseFirestore.instance
          .collection('ORDERS')
          .add(orderData);
      final String orderId = orderRef.id;

      try {
        final providerDocFull = await FirebaseFirestore.instance
            .collection('FOOD_PROVIDERS')
            .doc(realProviderId)
            .get();

        final String? providerToken = providerDocFull.data()?['fcmToken'];
        if (providerToken != null && providerToken.isNotEmpty) {
          await NotificationService.sendNotification(
            fcmToken: providerToken,
            title: "New Order Received! 🍽️",
            body: "You have a new order waiting for your approval.",
            orderId: orderId,
            type: "order",
          );
        }

        await FirebaseFirestore.instance.collection('USER_NOTIFICATIONS').add({
          'userId': realProviderId,
          'title': "New Order Received! 🍽️",
          'body': "You have a new order waiting for your approval.",
          'type': "order",
          'isRead': false,
          'orderId': orderId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (notifError) {
        debugPrint("Notification error (non-critical): $notifError");
      }

      for (var item in items) {
        try {
          final productQuery = await FirebaseFirestore.instance
              .collection('PRODUCT')
              .where('Name', isEqualTo: item.title)
              .where('Provider_ID', isEqualTo: realProviderId)
              .limit(1)
              .get();

          if (productQuery.docs.isNotEmpty) {
            final doc = productQuery.docs.first;
            final currentQty = (doc.data()['qty'] ?? 0) as int;
            final newQty = (currentQty - item.qty).clamp(0, 999999);
            await doc.reference.update({'qty': newQty});
          }

          final menuQuery = await FirebaseFirestore.instance
              .collection('FOOD_PROVIDERS')
              .doc(realProviderId)
              .collection('MENU')
              .where('name', isEqualTo: item.title)
              .limit(1)
              .get();

          if (menuQuery.docs.isNotEmpty) {
            final menuDoc = menuQuery.docs.first;
            final currentAvailable = (menuDoc.data()['available'] ?? 0) as int;
            final newAvailable = (currentAvailable - item.qty).clamp(0, 999999);
            await menuDoc.reference.update({'available': newAvailable});
          }
        } catch (e) {
          debugPrint("qty update error for ${item.title}: $e");
        }
      }

      CartData.cartItems.clear();
      CartData.currentRestaurant = "";
      CartData.currentRestaurantImage = "";

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ActiveOrdersEmptyScreen()),
            (route) => false,
      );
    } catch (e) {
      debugPrint("Error placing order: $e");
      _showSnack(
          "An error occurred while placing the order. Please try again.",
          Colors.red);
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Widget _selectionCard({required IconData icon, required String text}) {
    final bool isDefault =
        text == "Tap to select address" || text == "Tap to select payment";
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
          Icon(icon, color: isDefault ? Colors.grey : Colors.deepOrange),
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

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.brown,
        ),
      ),
    );
  }
}