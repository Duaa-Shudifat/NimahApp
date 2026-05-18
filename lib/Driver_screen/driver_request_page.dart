import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Customer_screen/Notification/notification_service.dart';
import '../Customer_screen/1.Launch/launch_welcome_screen.dart';
import 'package:geolocator/geolocator.dart';

// ─────────────────────────────────────────
// Driver Requests Page
// ─────────────────────────────────────────
class DriverRequestsPage extends StatefulWidget {
  const DriverRequestsPage({super.key});

  @override
  State<DriverRequestsPage> createState() => _DriverRequestsPageState();
}

class _DriverRequestsPageState extends State<DriverRequestsPage> {
  int selectedIndex = 0;
  final String driverUid = FirebaseAuth.instance.currentUser?.uid ?? "";
  StreamSubscription<Position>? _locationSubscription;

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking(String orderId) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _locationSubscription?.cancel();
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      FirebaseFirestore.instance.collection('ORDERS').doc(orderId).update({
        'Driver_Lat': position.latitude,
        'Driver_Lng': position.longitude,
      });
    });
  }

  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  void logout(BuildContext context) {
    _stopLocationTracking();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LaunchWelcomeScreen()),
          (route) => false,
    );
  }

  Query get _query {
    final base = FirebaseFirestore.instance.collection('ORDERS');
    if (selectedIndex == 0) {
      return base
          .where('Status', isEqualTo: 'Accepted')
          .where('Driver_ID', isEqualTo: '')
          .orderBy('Order_Date', descending: true);
    } else if (selectedIndex == 1) {
      return base
          .where('Status', isEqualTo: 'On the Way')
          .where('Driver_ID', isEqualTo: driverUid)
          .orderBy('Order_Date', descending: true);
    } else {
      return base
          .where('Status', whereIn: ['Delivered', 'Cancelled'])
          .where('Driver_ID', isEqualTo: driverUid)
          .orderBy('Order_Date', descending: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      appBar: AppBar(
        title: const Text(
          "Delivery Dashboard",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delivery_dining,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          selectedIndex == 0
                              ? "No new orders available"
                              : "Nothing here yet",
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final doc = orders[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _DriverOrderCard(
                      orderId: doc.id,
                      data: data,
                      driverUid: driverUid,
                      tabIndex: selectedIndex,
                      onAccepted: (orderId) => _startLocationTracking(orderId),
                      onDelivered: () => _stopLocationTracking(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton("New", 0),
          _buildTabButton("My Tasks", 1),
          _buildTabButton("History", 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final bool isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Driver Order Card
// ─────────────────────────────────────────
class _DriverOrderCard extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> data;
  final String driverUid;
  final int tabIndex;
  final Function(String orderId) onAccepted;
  final VoidCallback onDelivered;

  const _DriverOrderCard({
    required this.orderId,
    required this.data,
    required this.driverUid,
    required this.tabIndex,
    required this.onAccepted,
    required this.onDelivered,
  });

  @override
  State<_DriverOrderCard> createState() => _DriverOrderCardState();
}

class _DriverOrderCardState extends State<_DriverOrderCard> {
  bool _isLoading = false;

  // =====================
  // Accept Order (Pick Up)
  // =====================
  Future<void> _acceptOrder() async {
    setState(() => _isLoading = true);
    try {
      final docRef = FirebaseFirestore.instance.collection('ORDERS').doc(widget.orderId);
      final orderSnap = await docRef.get();
      final orderData = orderSnap.data() as Map<String, dynamic>;
      final customerId = orderData['Customer_ID'];

      if (orderData['Driver_ID'] != '') {
        throw Exception("Order already taken");
      }

      await docRef.update({
        'Driver_ID': widget.driverUid,
        'Status': 'On the Way',
      });

      // جلب توكن العميل
      final customerDoc = await FirebaseFirestore.instance.collection('CUSTOMERS').doc(customerId).get();
      final fcmToken = customerDoc['fcmToken'];

      if (fcmToken != null) {
        await NotificationService.sendNotification(
          fcmToken: fcmToken,
          title: "Delivery on the way",
          body: "The driver has picked up your order.",
          orderId: widget.orderId,
          type: "delivery",
        );
        await FirebaseFirestore.instance.collection('USER_NOTIFICATIONS').add({
          'userId': customerId,
          'title': "Delivery on the way",
          'body': "The driver has picked up your order.",
          'type': "delivery",
          'orderId': widget.orderId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      widget.onAccepted(widget.orderId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ));
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // =====================
  // Mark Delivered
  // =====================
  Future<void> _markDelivered() async {
    final docRef = FirebaseFirestore.instance.collection('ORDERS').doc(widget.orderId);
    final orderSnap = await docRef.get();
    final orderData = orderSnap.data() as Map<String, dynamic>;
    final customerId = orderData['Customer_ID'];

    await docRef.update({'Status': 'Delivered'});

    // توكن العميل
    final customerDoc = await FirebaseFirestore.instance.collection('CUSTOMERS').doc(customerId).get();
    final fcmToken = customerDoc['fcmToken'];

    if (fcmToken != null) {
      await NotificationService.sendNotification(
        fcmToken: fcmToken,
        title: "Order delivered! Please rate us",
        body: "Enjoy your meal! Please leave your rating.",
        orderId: widget.orderId,
        type: "delivery",
      );
      await FirebaseFirestore.instance.collection('USER_NOTIFICATIONS').add({
        'userId': customerId,
        'title': "Order delivered! Please rate us",
        'body': "Enjoy your meal! Please leave your rating.",
        'type': "delivery",
        'orderId': widget.orderId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    widget.onDelivered();
  }

  @override
  Widget build(BuildContext context) {
    // build UI code هنا بدون تغيير
    return Container(); // اختصار لمكان الـ UI
  }
}